{{/* vim: set filetype=mustache: */}}
{{/*
Rozwiń nazwę diagramu.
*/}}
{{- define "shipitclicker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Utwórz domyślną w pełni kwalifikowaną nazwę aplikacji.
Skracamy do 63 znaków, ponieważ niektóre pola  Kubernetes mają taką długość (specyfikacja nazw DNS).
Jeśli nazwa wersji zawiera nazwę diagramu, będzie używana jako pełna nazwa.
*/}}
{{- define "shipitclicker.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Utwórz nazwę i wersję zgodnie z etykietą diagramu.
*/}}
{{- define "shipitclicker.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Typowe etykiety.
*/}}
{{- define "shipitclicker.labels" -}}
helm.sh/chart: {{ include "shipitclicker.chart" . }}
{{ include "shipitclicker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Etykiety selektorów
*/}}
{{- define "shipitclicker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "shipitclicker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Utwórz nazwę konta usługi, którego chcesz używać
*/}}
{{- define "shipitclicker.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "shipitclicker.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
