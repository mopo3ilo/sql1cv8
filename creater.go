package sql1cv8

import (
	"database/sql"
	"encoding/json"
	"io"
	"os"

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

	m.Language = "ru"
	m.Objects = make(map[string]*Object, 65536)
	err = base.QueryRow(qryGetDBVersion).Scan(&m.Version)
	if err != nil {
		return
	}

	obj, err := initObjects(base, &m)
	if err != nil {
		return
	}
	obj.typesInsert()

	rows, err := base.Query(qryGetDB[m.Language])
	if err != nil {
		return
	}
	defer rows.Close()

	var (
		tn, vn, to, vo               string
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

		tn = tablePrefix + tableNumber + tableSuffix
		if to != tn {
			to = tn
			tableObject, ttExist = obj.obj(dataType, tableNumber, tableName, tablePrefix, tableSuffix)
			if !ttExist {
				continue
			}
			ttCVName = tableObject.CVName
			m.Objects[ttCVName] = tableObject

			switch dataType {
			case "Enum":
				obj.enumsInsert(tableObject)
			case "BPrPoints":
				obj.pointsInsert(tableObject)
			}
			obj.rtrefInsert(tableObject)

			vo = ""
			vtExist = true
		}
		if !ttExist {
			continue
		}

		vn = vtPrefix + vtNumber + vtSuffix
		if vo != vn {
			vo = vn
			tableObject, vtExist = obj.obj("VT", vtNumber, tableName, ttCVName+vtPrefix, vtSuffix)
			if !vtExist {
				continue
			}
			vtCVName = tableObject.CVName
			m.Objects[vtCVName] = tableObject
		}
		if !vtExist {
			continue
		}

		fieldObject, flExist = obj.obj("Fld", fieldNumber, fieldName, fieldPrefix, fieldSuffix)
		if !flExist {
			continue
		}
		flCVName = fieldObject.CVName
		tableObject.Params[flCVName] = fieldObject
	}

	return
}
