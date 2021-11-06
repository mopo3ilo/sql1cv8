package sql1cv8

import _ "embed"

var (
	//go:embed queries/getDBVersion.sql
	qryGetDBVersion string
	//go:embed queries/getDB.sql
	qryGetDB string
	//go:embed queries/getCVNames.sql
	qryGetCVNames string
	//go:embed queries/getDBNames.sql
	qryGetDBNames string
)
