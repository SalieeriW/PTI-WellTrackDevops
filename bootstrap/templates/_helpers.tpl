{{/*
get '-' from the string
*/}}
{{- define "get-value" -}}
{{- $parts := split "." . -}}
{{- $obj := $.Values -}}
{{- range $parts -}}
  {{- if contains "-" . -}}
    {{- $obj = index $obj . -}}
  {{- else -}}
    {{- $obj = pluck . (dict . $obj) | first -}}
  {{- end -}}
{{- end -}}
{{- $obj -}}
{{- end -}}