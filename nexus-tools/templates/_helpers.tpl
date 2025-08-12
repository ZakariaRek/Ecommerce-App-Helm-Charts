{{/*
Expand the name of the chart.
*/}}
{{- define "nexus-tools.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nexus-tools.fullname" -}}
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
{{- define "nexus-tools.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nexus-tools.labels" -}}
helm.sh/chart: {{ include "nexus-tools.chart" . }}
{{ include "nexus-tools.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment }}
component: tools
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nexus-tools.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nexus-tools.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Kafka UI labels
*/}}
{{- define "nexus-tools.kafkaui.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: messaging
service-type: kafka-ui
{{- end }}

{{/*
Prometheus labels
*/}}
{{- define "nexus-tools.prometheus.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: monitoring
service-type: prometheus
{{- end }}

{{/*
Grafana labels
*/}}
{{- define "nexus-tools.grafana.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: monitoring
service-type: grafana
{{- end }}

{{/*
Swagger UI labels
*/}}
{{- define "nexus-tools.swaggerui.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: documentation
service-type: swagger-ui
{{- end }}

{{/*
Adminer labels
*/}}
{{- define "nexus-tools.adminer.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: database
service-type: adminer
{{- end }}

{{/*
pgAdmin labels
*/}}
{{- define "nexus-tools.pgadmin.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: database
service-type: pgadmin
{{- end }}

{{/*
Redis Commander labels
*/}}
{{- define "nexus-tools.rediscommander.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: cache
service-type: redis-commander
{{- end }}

{{/*
Jaeger labels
*/}}
{{- define "nexus-tools.jaeger.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: observability
service-type: jaeger
{{- end }}

{{/*
Kiali labels
*/}}
{{- define "nexus-tools.kiali.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: observability
service-type: kiali
{{- end }}

{{/*
ElasticSearch labels
*/}}
{{- define "nexus-tools.elasticsearch.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: logging
service-type: elasticsearch
{{- end }}

{{/*
Kibana labels
*/}}
{{- define "nexus-tools.kibana.labels" -}}
{{ include "nexus-tools.labels" . }}
tier: logging
service-type: kibana
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nexus-tools.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nexus-tools.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified name for a specific service
*/}}
{{- define "nexus-tools.serviceName" -}}
{{- $serviceName := index . 0 -}}
{{- $context := index . 1 -}}
{{- printf "%s-%s" (include "nexus-tools.fullname" $context) $serviceName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "nexus-tools.annotations" -}}
deployment.kubernetes.io/revision: "1"
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- end }}

{{/*
Security context for tools
*/}}
{{- define "nexus-tools.securityContext" -}}
runAsNonRoot: true
runAsUser: 1000
fsGroup: 2000
{{- end }}

{{/*
Standard resource requirements
*/}}
{{- define "nexus-tools.resources" -}}
{{- if . }}
resources:
  {{- if .requests }}
  requests:
    {{- if .requests.memory }}
    memory: {{ .requests.memory }}
    {{- end }}
    {{- if .requests.cpu }}
    cpu: {{ .requests.cpu }}
    {{- end }}
  {{- end }}
  {{- if .limits }}
  limits:
    {{- if .limits.memory }}
    memory: {{ .limits.memory }}
    {{- end }}
    {{- if .limits.cpu }}
    cpu: {{ .limits.cpu }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}