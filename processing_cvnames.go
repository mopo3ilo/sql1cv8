package sql1cv8

type cvnames struct {
	m map[string]*cvname
}
type cvname struct {
	val string
	syn map[string]string
}

func processingCVNames(bin []byte) (c *cvnames) {
	c = &cvnames{
		m: make(map[string]*cvname, 65536),
	}

	var (
		i string
		l string
	)
	pd := processing(bin)
	for pd.next() {
		level, posit, _ := pd.get()
		if level == 1 && posit == 1 {
			break
		}
	}
	for pd.next() {
		level, posit, value := pd.get()
		switch level {
		case 2:
			switch posit % 7 {
			case 1:
				i = value
			case 4:
				c.m[i] = &cvname{
					val: value,
					syn: make(map[string]string),
				}
			}
		case 4:
			switch posit {
			case 0:
				l = value
			case 1:
				c.m[i].syn[l] = value
			}
		}
	}

	return c
}
