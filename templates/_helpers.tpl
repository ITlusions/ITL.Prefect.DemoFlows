{{/* Define a helper to get the current timestamp */}}
{{- define "getCurrentTimestamp" -}}
{{- now | date "2000-01-01T00:00:00" -}}
{{- end -}}
