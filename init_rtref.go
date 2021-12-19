package sql1cv8

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
