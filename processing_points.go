package sql1cv8

type points []*point
type point struct {
	num string
	val string
	syn map[string]string
}

func processingPoints(bin []byte) (ps points) {
	var (
		n string
		l string
		y bool
		p *point
		s map[string]string
	)
	ps = make(points, 0, 16)
	pd := processing(bin)
	for pd.next() {
		level, posit, _ := pd.get()
		if level == 1 && posit == 3 {
			break
		}
	}
	for pd.next() {
		level, posit, value := pd.get()
		switch level {
		case 3:
			if y {
				for pd.next() {
					if level, _, _ := pd.get(); level == 1 {
						break
					}
				}
				y = false
			}
		case 4:
			switch posit {
			case 0:
				s = make(map[string]string, 1)
				y = true
			case 3:
				n = value
			case 4:
				p = &point{
					num: value,
					val: n,
					syn: s,
				}
				ps = append(ps, p)
			}
		case 6:
			switch posit {
			case 0:
				l = value
			case 1:
				s[l] = value
			}
		}
	}

	return
}
