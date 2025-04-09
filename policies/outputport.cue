import "strings"

import "list"

let splits = strings.Split(id, ":")
let domain = splits[3]
let majorVersion = splits[5]

#ComponentVersion: string & =~"^([0-9]+\\.[0-9]+\\..+)$"
#Id:               string & =~"^[a-zA-Z0-9:._\\-]+$"
#ComponentId:      #Id & =~"^urn:dmb:cmp:\(domain):[a-zA-Z0-9_\\-]+:\(majorVersion):[a-zA-Z0-9_\\-]+$"

#BigQuery_DataType: string & =~"(?i)^(STRING|INTEGER|FLOAT|NUMERIC|BIGNUMERIC|BOOLEAN|TIMESTAMP|DATE|TIME|DATETIME|JSON|GEOGRAPHY|BYTES)$"
#RoundingMode:      string & =~"(?i)^(ROUNDING_MODE_UNSPECIFIED|ROUND_HALF_AWAY_FROM_ZERO|ROUND_HALF_EVEN)$"
#URL:               string & =~"^https?://[a-zA-Z0-9@:%._~#=&/?]*$"
#OM_Tag: {
	tagFQN!:      string
	description?: string | null
	source!:      string & =~"(?i)^(Classification|Glossary)$"
	labelType!:   string & =~"(?i)^(Manual|Propagated|Automated|Derived)$"
	state!:       string & =~"(?i)^(Suggested|Confirmed)$"
	href?:        string | null
	...
}

#BigQuery_Column: {
	name!:       string
	dataType!:   #BigQuery_DataType
	constraint?: string & =~"(?i)^(NULLABLE|REQUIRED|REPEATED)$" | null
	if dataType =~ "(?i)^(STRING|BYTES)$" {
		dataLength?: int & >0 | null
	}
	if dataType =~ "(?i)^(NUMERIC)$" {
		scale?:        int & >=0 & <=9
		precision?:    int & >0 & >scale & <=(scale + 29)
		roundingMode?: #RoundingMode | null
	}
	if dataType =~ "(?i)^(BIGNUMERIC)$" {
		scale?:        int & >=0 & <=38
		precision?:    int & >0 & >scale & <=(scale + 38)
		roundingMode?: #RoundingMode | null
	}
	description?: string | null
	tags?: [... #OM_Tag]
	...
}

#DataContract: {
	schema!: [...#BigQuery_Column]
	SLA: {
		intervalOfChange?: string | null
		timeliness?:       string | null
		upTime?:           string | null
		...
	}
	termsAndConditions?: string | null
	endpoint?:           #URL | null
	...
}

#DataSharingAgreement: {
	purpose?:         string | null
	billing?:         string | null
	security?:        string | null
	intendedUsage?:   string | null
	limitations?:     string | null
	lifeCycle?:       string | null
	confidentiality?: string | null
	...
}

id!:                       #ComponentId
name!:                     string
fullyQualifiedName?:       null | string
description!:              string
kind!:                     "outputport"
version!:                  string & =~"^[0-9]+\\.[0-9]+\\..+$"
infrastructureTemplateId!: string
useCaseTemplateId!:        string
dependsOn: [...#ComponentId]
platform!:            "GCP"
technology!:          "BigQuery"
outputPortType!:      "SQL"
dataContract:         #DataContract
dataSharingAgreement: #DataSharingAgreement
tags: [...#OM_Tag]
specific: {
	project!:   string & =~"^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$" & !~"google|ssl"
	dataset!:   string & =~"^[a-zA-Z0-9_]+$"
	tableName!: string
	viewName!:  string
	ownerRoles!: [...string]
}
