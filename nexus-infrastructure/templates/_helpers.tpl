{{/*
Expand the name of the chart.
*/}}
{{- define "nexus-infrastructure.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nexus-infrastructure.fullname" -}}
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
{{- define "nexus-infrastructure.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nexus-infrastructure.labels" -}}
helm.sh/chart: {{ include "nexus-infrastructure.chart" . }}
{{ include "nexus-infrastructure.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment }}
component: infrastructure
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nexus-infrastructure.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nexus-infrastructure.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Eureka labels
*/}}
{{- define "nexus-infrastructure.eureka.labels" -}}
{{ include "nexus-infrastructure.labels" . }}
tier: discovery
service-type: eureka
{{- end }}

{{/*
Config Server labels
*/}}
{{- define "nexus-infrastructure.configserver.labels" -}}
{{ include "nexus-infrastructure.labels" . }}
tier: configuration
service-type: config-server
{{- end }}

{{/*
API Gateway labels
*/}}
{{- define "nexus-infrastructure.apigateway.labels" -}}
{{ include "nexus-infrastructure.labels" . }}
tier: gateway
service-type: api-gateway
{{- end }}

{{/*
Zipkin labels
*/}}
{{- define "nexus-infrastructure.zipkin.labels" -}}
{{ include "nexus-infrastructure.labels" . }}
tier: observability
service-type: zipkin
{{- end }}

{{/*
Ingress labels
*/}}
{{- define "nexus-infrastructure.ingress.labels" -}}
{{ include "nexus-infrastructure.labels" . }}
tier: ingress
service-type: nginx-ingress
{{- end }}