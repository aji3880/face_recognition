{{/* Generate a name for the resource */}}
{{- define "face-recognition.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Generate a full name including release */}}
{{- define "face-recognition.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "face-recognition.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
