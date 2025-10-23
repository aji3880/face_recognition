{{- define "face-recognition.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "face-recognition.fullname" -}}
{{- printf "%s-%s" (include "face-recognition.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
