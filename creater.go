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

	m.Objects = make(map[string]*Object)
	m.Language = "ru"
	err = base.QueryRow(qryGetDBVersion).Scan(&m.Version)
	if err != nil {
		return
	}

	types = typesLang[m.Language]
	initTypes(m)

	fields = fieldsLang[m.Language]
	obj, err := initObjects(base)
	if err != nil {
		return
	}

	rows, err := base.Query(qryGetDB[m.Language])
	if err != nil {
		return
	}
	defer rows.Close()

	var (
		tn, vn                       string
		ttExist, vtExist, flExist    bool
		ttCVName, vtCVName, flCVName string
		tableObject, fieldObject     *Object
	)

	for rows.Next() {
		var (
			dataType,
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
			tableObject, ttExist = obj(tableNumber, tableName, tablePrefix, tableSuffix, false)
			if !ttExist {
				continue
			}
			ttCVName = tableObject.CVName
			m.Objects[ttCVName] = tableObject

			switch dataType {
			case "Enum":
				err = initEnums(base, m, tableObject)
				if err != nil {
					return
				}
			case "BPrPoints":
				err = initPoints(base, m, tableObject)
				if err != nil {
					return
				}
			}
			initRTRef(m, tableObject)
			if err != nil {
				return
			}

			vn = ""
			vtExist = true
		}
		if !ttExist {
			continue
		}

		if vn != vtNumber {
			vn = vtNumber
			tableObject, vtExist = obj(vtNumber, tableName, ttCVName+vtPrefix, vtSuffix, false)
			if !vtExist {
				continue
			}
			vtCVName = tableObject.CVName
			m.Objects[vtCVName] = tableObject
		}
		if !vtExist {
			continue
		}

		fieldObject, flExist = obj(fieldNumber, fieldName, fieldPrefix, fieldSuffix, true)
		if !flExist {
			continue
		}
		flCVName = fieldObject.CVName
		tableObject.Params[flCVName] = fieldObject
	}

	return
}

func initObjects(base *sql.DB) (res func(n, t, p, s string, f bool) (*Object, bool), err error) {
	var (
		bin []byte
		val [][]string
		num map[string]string
		typ map[string]string
		ids map[string]string
		syn map[string]map[string]string
		reg *regexp.Regexp
	)

	err = base.QueryRow(qryGetDBNames).Scan(&bin)
	if err != nil {
		return
	}
	bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
	if err != nil {
		return
	}
	num = make(map[string]string)
	typ = make(map[string]string)
	reg = regexp.MustCompile(`{(\w{8}-\w{4}-\w{4}-\w{4}-\w{12}),"(\w+)",(\d+)}`)
	val = reg.FindAllStringSubmatch(string(bin), -1)
	for _, v := range val {
		var (
			i string = v[1]
			t string = v[2]
			n string = v[3]
		)
		if _, ok := num[n]; ok {
			continue
		}
		num[n] = i
		typ[n] = t
	}

	err = base.QueryRow(qryGetCVNames).Scan(&bin)
	if err != nil {
		return
	}
	bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
	if err != nil {
		return
	}
	ids = make(map[string]string)
	syn = make(map[string]map[string]string)
	reg = regexp.MustCompile(`(?sU),(\w{8}-\w{4}-\w{4}-\w{4}-\w{12}),\w{8}-\w{4}-\w{4}-\w{4}-\w{12},\d+,"([^"]+)",\r\n\{\d+,\d+(.*)\},\d+,\d+`)
	val = reg.FindAllStringSubmatch(string(bin), -1)
	reg = regexp.MustCompile(`\{"([^"]+)","([^"]+)"\}`)
	for _, v := range val {
		var (
			i string = v[1]
			n string = v[2]
			s string = v[3]
		)
		if _, ok := ids[i]; ok {
			continue
		}
		ids[i] = n
		syn[i] = make(map[string]string)
		val := reg.FindAllStringSubmatch(s, -1)
		for _, v := range val {
			var (
				l string = v[1]
				s string = v[2]
			)
			syn[i][l] = s
		}
	}

	res = func(n, t, p, s string, f bool) (obj *Object, ok bool) {
		if f {
			name, ok := fields[n]
			if ok {
				obj = &Object{
					Type:     n[1:],
					Number:   n,
					DBName:   t,
					CVName:   p + name + s,
					Synonyms: fieldSynonyms[n],
				}
				return obj, true
			}
		}

		i, ok := num[n]
		if !ok {
			return nil, false
		}
		name, ok := ids[i]
		if !ok {
			return nil, false
		}
		var m map[string]*Object
		if !f {
			m = make(map[string]*Object)
		}
		obj = &Object{
			UUID:     i,
			Type:     typ[n],
			Number:   n,
			DBName:   t,
			CVName:   p + name + s,
			Params:   m,
			Synonyms: syn[i],
		}
		return obj, true
	}

	return
}

func initTypes(m Metadata) {
	for value, name := range types {
		m.Objects[name] = &Object{
			Type:   "Type",
			DBName: value,
			CVName: name,
		}
	}
}

func initRTRef(m Metadata, o *Object) (err error) {
	t, err := o.RTRefBin()
	if err != nil {
		return
	}
	name := o.CVName + "." + fields["_IDTRef"]
	m.Objects[name] = &Object{
		Type:     "TRef",
		DBName:   t,
		CVName:   name,
		Synonyms: fieldSynonyms["_IDTRef"],
	}
	return
}

func initEnums(base *sql.DB, m Metadata, o *Object) (err error) {
	var (
		bin []byte
		val [][]string
		reg *regexp.Regexp
	)

	err = base.QueryRow("select BinaryData from Config where FileName = @p1", o.UUID).Scan(&bin)
	if err != nil {
		return
	}
	bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
	if err != nil {
		return
	}
	reg = regexp.MustCompile(`\{\d+,\d+,\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\},"([^"]+)",`)
	val = reg.FindAllStringSubmatch(string(bin), -1)
	for i, v := range val {
		if i == 0 {
			continue
		}
		name := o.CVName + "." + v[1]
		value := strconv.Itoa(i - 1)

		m.Objects[name] = &Object{
			Type:   "EnumOrder",
			DBName: value,
			CVName: name,
		}

		name = "$" + name
		m.Objects[name] = &Object{
			Type:   "EnumRRef",
			DBName: "(select top 1 _IDRRef from " + o.DBName + " where _EnumOrder = " + value + ")",
			CVName: name,
		}
	}

	return
}

func initPoints(base *sql.DB, m Metadata, o *Object) (err error) {
	var (
		bin []byte
		val [][]string
		reg *regexp.Regexp
	)

	err = base.QueryRow("select BinaryData from Config where FileName = @p1", o.UUID+".7").Scan(&bin)
	if err != nil {
		return
	}
	bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
	if err != nil {
		return
	}
	reg = regexp.MustCompile(`\},"([^"]+)",(\d+)\},\d+,\w{8}-\w{4}-\w{4}-\w{4}-\w{12},\d+\},\d+,`)
	val = reg.FindAllStringSubmatch(string(bin), -1)
	for _, v := range val {
		name := o.CVName + "." + v[1]
		value := v[2]

		m.Objects[name] = &Object{
			Type:   "RoutePointOrder",
			DBName: value,
			CVName: name,
		}

		name = "$" + name
		m.Objects[name] = &Object{
			Type:   "RoutePointRRef",
			DBName: "(select top 1 _IDRRef from " + o.DBName + " where _RoutePointOrder = " + value + ")",
			CVName: name,
		}
	}

	return
}
