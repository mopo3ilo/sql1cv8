package sql1cv8

import (
	"bytes"
	"compress/flate"
	"database/sql"
	"io"
)

type initedObjects struct {
	m       *Metadata
	fields  map[string]string
	types   map[string]string
	dbnames *dbnames
	cvnames *cvnames
	enums   map[string]enums
	points  map[string]points
}

func (obj *initedObjects) obj(n, t, p, s string, f bool) (o *Object, ok bool) {
	if f {
		name, ok := obj.fields[n]
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

func (obj *initedObjects) enumsInsert(o *Object) {
	var qc, qd string

	for _, e := range obj.enums[o.UUID] {
		name := o.CVName + "." + e.val
		obj.m.Objects[name] = &Object{
			Type:     "EnumOrder",
			DBName:   e.num,
			CVName:   name,
			Synonyms: e.syn,
		}

		qc += " when " + e.num + " then '" + e.val + "'"
		qd += " when " + e.num + " then '" + e.syn[obj.m.Language] + "'"

		name = "$" + name
		obj.m.Objects[name] = &Object{
			Type:   "EnumRRef",
			DBName: "(select top 1 _IDRRef from " + o.DBName + " where _EnumOrder = " + e.num + ")",
			CVName: name,
		}
	}

	name := "$" + o.CVName
	qry := "(select _IDRRef, case" + qc + " end _Code, case" + qd + " end _Description from " + o.DBName + ")"

	obj.m.Objects[name] = &Object{
		UUID:     o.UUID,
		Type:     "EnumVirtual",
		Number:   o.Number,
		DBName:   qry,
		CVName:   name,
		Synonyms: o.Synonyms,
		Params: map[string]*Object{
			obj.fields["_IDRRef"]: {
				Type:     "IDRRef",
				Number:   "_IDRRef",
				DBName:   "_IDRRef",
				CVName:   obj.fields["_IDRRef"],
				Synonyms: fieldSynonyms["_IDRRef"],
			},
			obj.fields["_Code"]: {
				Type:     "Code",
				Number:   "_Code",
				DBName:   "_Code",
				CVName:   obj.fields["_Code"],
				Synonyms: fieldSynonyms["_Code"],
			},
			obj.fields["_Description"]: {
				Type:     "Description",
				Number:   "_Description",
				DBName:   "_Description",
				CVName:   obj.fields["_Description"],
				Synonyms: fieldSynonyms["_Description"],
			},
		},
	}
}

func (obj *initedObjects) pointsInsert(o *Object) {
	var qc, qd string

	for _, p := range obj.points[o.UUID] {
		name := o.CVName + "." + p.val
		obj.m.Objects[name] = &Object{
			Type:     "RoutePointOrder",
			DBName:   p.num,
			CVName:   name,
			Synonyms: p.syn,
		}

		qc += " when " + p.num + " then '" + p.val + "'"
		qd += " when " + p.num + " then '" + p.syn[obj.m.Language] + "'"

		name = "$" + name
		obj.m.Objects[name] = &Object{
			Type:   "RoutePointRRef",
			DBName: "(select top 1 _IDRRef from " + o.DBName + " where _RoutePointOrder = " + p.num + ")",
			CVName: name,
		}
	}

	name := "$" + o.CVName
	qry := "(select _IDRRef, case" + qc + " end _Code, case" + qd + " end _Description from " + o.DBName + ")"

	obj.m.Objects[name] = &Object{
		UUID:     o.UUID,
		Type:     "RoutePointVirtual",
		Number:   o.Number,
		DBName:   qry,
		CVName:   name,
		Synonyms: o.Synonyms,
		Params: map[string]*Object{
			obj.fields["_IDRRef"]: {
				Type:     "IDRRef",
				Number:   "_IDRRef",
				DBName:   "_IDRRef",
				CVName:   obj.fields["_IDRRef"],
				Synonyms: fieldSynonyms["_IDRRef"],
			},
			obj.fields["_Code"]: {
				Type:     "Code",
				Number:   "_Code",
				DBName:   "_Code",
				CVName:   obj.fields["_Code"],
				Synonyms: fieldSynonyms["_Code"],
			},
			obj.fields["_Description"]: {
				Type:     "Description",
				Number:   "_Description",
				DBName:   "_Description",
				CVName:   obj.fields["_Description"],
				Synonyms: fieldSynonyms["_Description"],
			},
		},
	}
}

func (obj *initedObjects) rtrefInsert(o *Object) {
	t, err := o.RTRefBin()
	if err != nil {
		return
	}
	name := o.CVName + "." + obj.fields["_IDTRef"]
	obj.m.Objects[name] = &Object{
		Type:     "TRef",
		DBName:   t,
		CVName:   name,
		Synonyms: fieldSynonyms["_IDTRef"],
	}
}

func (obj *initedObjects) typesInsert() {
	for value, name := range obj.types {
		obj.m.Objects[name] = &Object{
			Type:   "Type",
			DBName: value,
			CVName: name,
		}
	}
}

func initObjects(base *sql.DB, metadata *Metadata) (obj *initedObjects, err error) {
	obj = &initedObjects{m: metadata}
	obj.types = types[obj.m.Language]
	obj.fields = fields[obj.m.Language]

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
