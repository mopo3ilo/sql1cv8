package sql1cv8

type dbnames struct {
	m         map[string]*dbname
	cntEnums  int
	qryEnums  string
	cntPoints int
	qryPoints string
}
type dbname struct {
	ids string
	typ string
	num string
}

func processingDBNames(bin []byte) (d *dbnames) {
	d = &dbnames{
		m: make(map[string]*dbname, 65536),
	}

	var (
		i string
		t string
		n string

		ce, cp int
		qe, qp string
	)
	pd := processing(bin)
	for pd.next() {
		level, posit, value := pd.get()
		if level == 3 {
			switch posit {
			case 0:
				i = value
			case 1:
				t = value
			case 2:
				n = value
				d.m[t+n] = &dbname{
					ids: i,
					typ: t,
					num: n,
				}

				switch t {
				case "Enum":
					ce++
					qe += ",'" + i + "'"
				case "BPrPoints":
					cp++
					qp += ",'" + i + ".7'"
				}
			}
		}
	}
	d.cntEnums = ce
	d.qryEnums = "select FileName, BinaryData from Config where FileName in (" + qe[1:] + ")"
	d.cntPoints = cp
	d.qryPoints = "select left(FileName, 36) FileName, BinaryData from Config where FileName in (" + qp[1:] + ")"

	return d
}
