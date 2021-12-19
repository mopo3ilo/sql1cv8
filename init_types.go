package sql1cv8

func initTypes(m Metadata) {
	for value, name := range types {
		m.Objects[name] = &Object{
			Type:   "Type",
			DBName: value,
			CVName: name,
		}
	}
}
