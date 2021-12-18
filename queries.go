package sql1cv8

import _ "embed"

var (
	//go:embed queries/getDBVersion.sql
	qryGetDBVersion string
	//go:embed queries/getDB_en.sql
	qryGetDBEn string
	//go:embed queries/getDB_ru.sql
	qryGetDBRu string
	//go:embed queries/getCVNames.sql
	qryGetCVNames string
	//go:embed queries/getDBNames.sql
	qryGetDBNames string
)

var qryGetDB = map[string]string{
	"en": qryGetDBEn,
	"ru": qryGetDBRu,
}
