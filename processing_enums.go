package sql1cv8

import "strconv"

type enums []*enum
type enum struct {
	num string
	val string
	syn map[string]string
}

func processingEnums(bin []byte) (es enums) {
	var (
		i int
		l string
		y bool
		e *enum
	)
	es = make(enums, 0, 16)
	pd := processing(bin)
	for pd.next() {
		level, posit, _ := pd.get()
		if level == 1 && posit == 5 {
			break
		}
	}
	for pd.next() {
		level, posit, value := pd.get()
		switch level {
		case 5:
			y = false
			if posit == 2 {
				e = &enum{
					num: strconv.Itoa(i),
					val: value,
					syn: make(map[string]string, 1),
				}
				es = append(es, e)
				i++
				y = true
			}
		case 6:
			if !y {
				continue
			}
			if posit == 0 {
				continue
			}
			switch posit % 2 {
			case 0:
				e.syn[l] = value
			case 1:
				l = value
			}
		}
	}

	return
}
