{{/* Define a helper to get the current timestamp */}}
{{- define "getCurrentTimestamp" -}}
{{- now | date "20060102150405" }}
{{- end -}}

{{- define "prefect.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- $fullname := printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- $fullname | replace "_" "-" | lower -}}
{{- end -}}