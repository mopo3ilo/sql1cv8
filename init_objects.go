package sql1cv8

import (
	"bytes"
	"compress/flate"
	"database/sql"
	"io"
)

type initedObjects struct {
	dbnames *dbnames
	cvnames *cvnames
	enums   map[string]enums
	points  map[string]points
}

func (obj *initedObjects) obj(n, t, p, s string, f bool) (o *Object, ok bool) {
	if f {
		name, ok := fields[n]
		if ok {
			o = &Object{
				Type:     n[1:],
				Number:   n,
				DBName:   t,
				CVName:   p + name + s,
				Synonyms: fieldSynonyms[n],
			}
			return o, true
		}
	}

	d, ok := obj.dbnames.m[n]
	if !ok {
		return nil, false
	}
	c, ok := obj.cvnames.m[d.ids]
	if !ok {
		return nil, false
	}
	var m map[string]*Object
	if !f {
		m = make(map[string]*Object)
	}
	o = &Object{
		UUID:     d.ids,
		Type:     d.typ,
		Number:   n,
		DBName:   t,
		CVName:   p + c.val + s,
		Params:   m,
		Synonyms: c.syn,
	}
	return o, true
}

func (obj *initedObjects) enumsInsert(m Metadata, o *Object) {
	for _, e := range obj.enums[o.UUID] {
		name := o.CVName + "." + e.val
		m.Objects[name] = &Object{
			Type:     "EnumOrder",
			DBName:   e.num,
			CVName:   name,
			Synonyms: e.syn,
		}

		name = "$" + name
		m.Objects[name] = &Object{
			Type:   "EnumRRef",
			DBName: "(select top 1 _IDRRef from " + o.DBName + " where _EnumOrder = " + e.num + ")",
			CVName: name,
		}
	}
}

func (obj *initedObjects) pointsInsert(m Metadata, o *Object) {
	for _, p := range obj.points[o.UUID] {
		name := o.CVName + "." + p.val
		m.Objects[name] = &Object{
			Type:     "RoutePointOrder",
			DBName:   p.num,
			CVName:   name,
			Synonyms: p.syn,
		}

		name = "$" + name
		m.Objects[name] = &Object{
			Type:   "RoutePointRRef",
			DBName: "(select top 1 _IDRRef from " + o.DBName + " where _RoutePointOrder = " + p.num + ")",
			CVName: name,
		}
	}
}

func initObjects(base *sql.DB) (obj *initedObjects, err error) {
	obj = &initedObjects{}

	var bin []byte

	err = base.QueryRow(qryGetDBNames).Scan(&bin)
	if err != nil {
		return
	}
	bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
	if err != nil {
		return
	}
	obj.dbnames = processingDBNames(bin)

	err = base.QueryRow(qryGetCVNames).Scan(&bin)
	if err != nil {
		return
	}
	bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
	if err != nil {
		return
	}
	obj.cvnames = processingCVNames(bin)

	var rows *sql.Rows

	rows, err = base.Query(obj.dbnames.qryEnums)
	if err != nil {
		return
	}
	obj.enums = make(map[string]enums, obj.dbnames.cntEnums)
	for rows.Next() {
		var i string
		err = rows.Scan(&i, &bin)
		if err != nil {
			return
		}
		bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
		if err != nil {
			return
		}
		obj.enums[i] = processingEnums(bin)
	}
	rows.Close()

	rows, err = base.Query(obj.dbnames.qryPoints)
	if err != nil {
		return
	}
	obj.points = make(map[string]points, obj.dbnames.cntPoints)
	for rows.Next() {
		var i string
		err = rows.Scan(&i, &bin)
		if err != nil {
			return
		}
		bin, err = io.ReadAll(flate.NewReader(bytes.NewReader(bin)))
		if err != nil {
			return
		}
		obj.points[i] = processingPoints(bin)
	}
	rows.Close()

	return
}
