package sql1cv8

import (
	"bytes"
	"compress/flate"
	"database/sql"
	"encoding/json"
	"io"
	"os"
	"regexp"
	"strconv"

	_ "github.com/denisenkom/go-mssqldb"
)

// LoadNewer возвращает метаданные из базы данных, либо из файла, если объекты в базе не менялись.
// В качестве параметров принимает две строковые переменные:
// cs - строка подключения, описание которой можно посмотреть по ссылке https://github.com/denisenkom/go-mssqldb#connection-parameters-and-dsn;
// s - имя файла, в котором хранится кэш метаданных в формате json.
// Возвращает объект Metadata.
func LoadNewer(cs, s string) (m Metadata, err error) {
	var version string
	m, err = LoadFromFile(s)
	if err != nil && !os.IsNotExist(err) {
		return
	}
	base, err := sql.Open("sqlserver", cs)
	if err != nil {
		return
	}
	defer base.Close()
	err = base.QueryRow(qryGetDBVersion).Scan(&version)
	if err != nil {
		return
	}
	if m.Version == version {
		return
	}
	m, err = LoadFromDB(cs)
	if err != nil {
		return
	}
	err = m.SaveToFile(s)
	return
}

// LoadFromDB возвращает метаданные.
// В качестве параметров принимает строковую переменную:
// cs - строка подключения, описание которой можно посмотреть по ссылке https://github.com/denisenkom/go-mssqldb#connection-parameters-and-dsn.
// Возвращает объект Metadata.
func LoadFromDB(cs string) (m Metadata, err error) {
	base, err := sql.Open("sqlserver", cs)
	if err != nil {
		return
	}
	defer base.Close()

	type list struct {
		names  map[string]string
		childs map[string][]string
	}

	var (
		bin  []byte
		val  [][]string
		reg  *regexp.Regexp
		rows *sql.Rows

		cv = list{
			names:  make(map[string]string),
			childs: make(map[string][]string),
		}
		db = list{
			names:  make(map[string]string),
			childs: make(map[string][]string),
		}
	)

	m.Tables = make(map[string]*Object)
	initConsts(m)

	err = base.QueryRow(qryGetDBVersion).Scan(&m.Version)
	if err != nil {
		return
	}

	err = base.QueryRow(qryGetCVNames).Scan(&bin)
	if err != nil {
		return
	}
	bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
	if err != nil {
		return
	}
	reg, err = regexp.Compile(`\d+,(\w{8}\-\w{4}\-\w{4}\-\w{4}\-\w{12}),(\w{8}\-\w{4}\-\w{4}\-\w{4}\-\w{12}),\d+,"(.+)",`)
	if err != nil {
		return
	}
	val = reg.FindAllStringSubmatch(string(bin), -1)
	cv.childs["00000000-0000-0000-0000-000000000000"] = make([]string, 0, 1)
	for _, v := range val {
		var (
			id       string = v[1]
			parentid string = v[2]
			name     string = v[3]
		)

		cv.names[id] = name
		cv.childs[id] = make([]string, 0, 10)
		cv.childs[parentid] = append(cv.childs[parentid], name)
	}

	err = base.QueryRow(qryGetDBNames).Scan(&bin)
	if err != nil {
		return
	}
	bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
	if err != nil {
		return
	}
	reg, err = regexp.Compile(`{(\w{8}\-\w{4}\-\w{4}\-\w{4}\-\w{12}),"\w+",(\d+)}`)
	if err != nil {
		return
	}
	val = reg.FindAllStringSubmatch(string(bin), -1)
	for _, v := range val {
		var (
			id     string = v[1]
			number string = v[2]
		)

		db.names[number] = cv.names[id]
		db.childs[number] = cv.childs[id]
	}

	rows, err = base.Query(qryGetDB)
	if err != nil {
		return
	}
	defer rows.Close()

	var (
		tn, vn                   string
		tableCVName              string
		tableObject, fieldObject *Object
	)

	for rows.Next() {
		var (
			dataType,
			tableType,
			tableName,
			fieldName,
			tablePrefix,
			tableNumber,
			tableSuffix,
			vtPrefix,
			vtNumber,
			vtSuffix,
			fieldPrefix,
			fieldNumber,
			fieldSuffix string
		)
		err = rows.Scan(
			&dataType,
			&tableName,
			&fieldName,
			&tablePrefix,
			&tableNumber,
			&tableSuffix,
			&vtPrefix,
			&vtNumber,
			&vtSuffix,
			&fieldPrefix,
			&fieldNumber,
			&fieldSuffix,
		)
		if err != nil {
			return
		}

		if tn != tableNumber {
			tn = tableNumber
			vn = ""
			tableCVName = tablePrefix + db.names[tableNumber] + tableSuffix

			if dataType == "Enum" {
				for i, v := range db.childs[tableNumber] {
					name := tableCVName + "." + v
					m.Tables[name] = &Object{
						DBName: strconv.Itoa(i),
						CVName: name,
					}
				}
			}

			tableObject = &Object{
				Number: tableNumber,
				DBName: tableName,
				CVName: tableCVName,
				Fields: make(map[string]*Object),
			}
			m.Tables[tableObject.CVName] = tableObject

			{
				tableType, err = tableObject.RTRefBin()
				if err != nil {
					return
				}
				name := tableCVName + ".ВидСсылки"
				m.Tables[name] = &Object{
					DBName: tableType,
					CVName: "ВидСсылки",
				}
			}
		}

		if vn != vtNumber {
			vn = vtNumber

			tableObject = &Object{
				Number: vtNumber,
				DBName: tableName,
				CVName: tableCVName + vtPrefix + db.names[vtNumber] + vtSuffix,
				Fields: make(map[string]*Object),
			}
			m.Tables[tableObject.CVName] = tableObject
		}

		fieldObject = &Object{
			Number: fieldNumber,
			DBName: fieldName,
			CVName: fieldPrefix + db.names[fieldNumber] + fieldSuffix,
		}
		tableObject.Fields[fieldObject.CVName] = fieldObject
	}

	return
}

// LoadFromFile возвращает метаданные из файла.
// В качестве параметров принимает строковую переменную:
// s - имя файла, в котором хранится кэш метаданных в формате json.
// Возвращает объект Metadata.
func LoadFromFile(s string) (m Metadata, err error) {
	f, err := os.Open(s)
	if err != nil {
		return
	}
	defer f.Close()
	b, err := io.ReadAll(f)
	if err != nil {
		return
	}
	err = json.Unmarshal(b, &m)
	return
}

// SaveToFile сохраняет метаданные в файл.
// В качестве параметров принимает строковую переменную:
// s - имя файла, в котором хранится кэш метаданных в формате json.
func (m Metadata) SaveToFile(s string) (err error) {
	b, err := json.Marshal(m)
	if err != nil {
		return
	}
	f, err := os.Create(s)
	if err != nil {
		return
	}
	defer f.Close()
	_, err = f.Write(b)
	if err != nil {
		return
	}
	return
}
