package sql1cv8

type processingData struct {
	bin []byte

	currentLevel int
	currentPosit []int

	lastLevel int
	lastPosit int
	lastValue []byte
}

func processing(bin []byte) *processingData {
	return &processingData{
		bin:          bin[3:],
		currentPosit: make([]int, 64),
	}
}

func (pd *processingData) get() (int, int, string) {
	return pd.lastLevel, pd.lastPosit, string(pd.lastValue)
}

func (pd *processingData) next() bool {
	pd.lastValue = make([]byte, 0, 256)
	var isString bool
	for i, v := range pd.bin {
		switch v {
		case 123: // {
			pd.currentLevel++
			pd.currentPosit[pd.currentLevel] = 0
			continue
		case 125: // }
			pd.bin = pd.bin[i+1:]
			pd.lastLevel = pd.currentLevel
			pd.lastPosit = pd.currentPosit[pd.currentLevel]
			pd.currentLevel--
			return true
		case 44: // ,
			pd.bin = pd.bin[i+1:]
			pd.lastLevel = pd.currentLevel
			pd.lastPosit = pd.currentPosit[pd.currentLevel]
			pd.currentPosit[pd.currentLevel]++
			return true
		case 34: // "
			if isString && pd.bin[i+1] == 34 {
				isString = false
			} else {
				isString = !isString
				continue
			}
		case 10, 13:
			if !isString {
				continue
			}
		}
		pd.lastValue = append(pd.lastValue, v)
	}
	return false
}
