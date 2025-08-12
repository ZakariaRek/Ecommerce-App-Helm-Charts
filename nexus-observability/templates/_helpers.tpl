{{/*
Expand the name of the chart.
*/}}
{{- define "nexus-observability.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nexus-observability.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nexus-observability.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nexus-observability.labels" -}}
helm.sh/chart: {{ include "nexus-observability.chart" . }}
{{ include "nexus-observability.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment }}
component: observability
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nexus-observability.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nexus-observability.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Prometheus labels
*/}}
{{- define "nexus-observability.prometheus.labels" -}}
{{ include "nexus-observability.labels" . }}
tier: monitoring
service-type: prometheus
{{- end }}

{{/*
Grafana labels
*/}}
{{- define "nexus-observability.grafana.labels" -}}
{{ include "nexus-observability.labels" . }}
tier: visualization
service-type: grafana
{{- end }}

{{/*
Elasticsearch labels
*/}}
{{- define "nexus-observability.elasticsearch.labels" -}}
{{ include "nexus-observability.labels" . }}
tier: logging
service-type: elasticsearch
{{- end }}

{{/*
Kibana labels
*/}}
{{- define "nexus-observability.kibana.labels" -}}
{{ include "nexus-observability.labels" . }}
tier: logging
service-type: kibana
{{- end }}

{{/*
Logstash labels
*/}}
{{- define "nexus-observability.logstash.labels" -}}
{{ include "nexus-observability.labels" . }}
tier: logging
service-type: logstash
{{- end }}

{{/*
Kiali labels
*/}}
{{- define "nexus-observability.kiali.labels" -}}
{{ include "nexus-observability.labels" . }}
tier: service-mesh
service-type: kiali
{{- end }}