{{/*
Expand the name of the chart.
*/}}
{{- define "nexus-microservices.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nexus-microservices.fullname" -}}
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
{{- define "nexus-microservices.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nexus-microservices.labels" -}}
helm.sh/chart: {{ include "nexus-microservices.chart" . }}
{{ include "nexus-microservices.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment }}
component: microservices
platform: nexus-commerce
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nexus-microservices.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nexus-microservices.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
User Service labels
*/}}
{{- define "nexus-microservices.userservice.labels" -}}
{{ include "nexus-microservices.labels" . }}
tier: backend
service-type: user-service
{{- end }}

{{/*
Product Service labels
*/}}
{{- define "nexus-microservices.productservice.labels" -}}
{{ include "nexus-microservices.labels" . }}
tier: backend
service-type: product-service
{{- end }}

{{/*
Cart Service labels
*/}}
{{- define "nexus-microservices.cartservice.labels" -}}
{{ include "nexus-microservices.labels" . }}
tier: backend
service-type: cart-service
{{- end }}

{{/*
Order Service labels
*/}}
{{- define "nexus-microservices.orderservice.labels" -}}
{{ include "nexus-microservices.labels" . }}
tier: backend
service-type: order-service
{{- end }}

{{/*
Payment Service labels
*/}}
{{- define "nexus-microservices.paymentservice.labels" -}}
{{ include "nexus-microservices.labels" . }}
tier: business-logic
service-type: payment-service
{{- end }}

{{/*
Notification Service labels
*/}}
{{- define "nexus-microservices.notificationservice.labels" -}}
{{ include "nexus-microservices.labels" . }}
tier: backend
service-type: notification-service
{{- end }}

{{/*
Loyalty Service labels
*/}}
{{- define "nexus-microservices.loyaltyservice.labels" -}}
{{ include "nexus-microservices.labels" . }}
tier: backend
service-type: loyalty-service
{{- end }}

{{/*
Shipping Service labels
*/}}
{{- define "nexus-microservices.shippingservice.labels" -}}
{{ include "nexus-microservices.labels" . }}
tier: backend
service-type: shipping-service
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nexus-microservices.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nexus-microservices.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common environment variables for all microservices
*/}}
{{- define "nexus-microservices.commonEnvVars" -}}
- name: SPRING_PROFILES_ACTIVE
  value: {{ .values.config.profiles.active | quote }}
- name: SPRING_APPLICATION_NAME
  value: {{ .serviceName | quote }}
- name: SERVER_PORT
  value: {{ .values.service.port | quote }}
- name: EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE
  value: {{ .Values.global.infrastructure.eureka.url | quote }}
- name: EUREKA_INSTANCE_HOSTNAME
  value: {{ .serviceName | quote }}
- name: SPRING_CLOUD_CONFIG_URI
  value: {{ .Values.global.infrastructure.configServer.url | quote }}
- name: SPRING_KAFKA_BOOTSTRAP_SERVERS
  value: {{ .Values.global.data.kafka.brokers | quote }}
{{- if .Values.global.data.redis.enabled }}
- name: SPRING_DATA_REDIS_HOST
  value: {{ .Values.global.data.redis.host | quote }}
- name: SPRING_DATA_REDIS_PORT
  value: {{ .Values.global.data.redis.port | quote }}
{{- end }}
{{- end }}

{{/*
Common init containers for all microservices
*/}}
{{- define "nexus-microservices.commonInitContainers" -}}
- name: wait-for-eureka
  image: busybox:1.35
  command: ['sh', '-c']
  args:
    - |
      echo "Waiting for Eureka..."
      until nc -z eureka-server.{{ .Values.global.infrastructure.namespace }}.svc.cluster.local 8761; do 
        echo "Eureka not ready, waiting..."
        sleep 5
      done
      echo "Eureka is ready!"
- name: wait-for-config-server
  image: busybox:1.35
  command: ['sh', '-c']
  args:
    - |
      echo "Waiting for Config Server..."
      until nc -z config-server.{{ .Values.global.infrastructure.namespace }}.svc.cluster.local 8888; do 
        echo "Config Server not ready, waiting..."
        sleep 3
      done
      echo "Config Server is ready!"
{{- if .Values.global.data.kafka.enabled }}
- name: wait-for-kafka
  image: busybox:1.35
  command: ['sh', '-c']
  args:
    - |
      echo "Waiting for Kafka..."
      until nc -z kafka-service.{{ .Values.global.data.namespace }}.svc.cluster.local 9092; do 
        echo "Kafka not ready, waiting..."
        sleep 3
      done
      echo "Kafka is ready!"
{{- end }}
{{- end }}

{{/*
Common volume mounts for all microservices
*/}}
{{- define "nexus-microservices.commonVolumeMounts" -}}
- name: config-volume
  mountPath: /app/config
- name: logs-volume
  mountPath: /app/logs
- name: tmp-volume
  mountPath: /tmp
{{- end }}

{{/*
Common volumes for all microservices
*/}}
{{- define "nexus-microservices.commonVolumes" -}}
- name: config-volume
  configMap:
    name: {{ .serviceName }}-config
- name: logs-volume
  emptyDir: {}
- name: tmp-volume
  emptyDir: {}
{{- end }}

{{/*
Common health check configuration
*/}}
{{- define "nexus-microservices.healthChecks" -}}
livenessProbe:
  httpGet:
    path: {{ .contextPath }}/actuator/health
    port: {{ .port }}
  initialDelaySeconds: 180
  periodSeconds: 45
  timeoutSeconds: 15
  failureThreshold: 5
readinessProbe:
  httpGet:
    path: {{ .contextPath }}/actuator/health/readiness
    port: {{ .port }}
  initialDelaySeconds: 120
  periodSeconds: 15
  timeoutSeconds: 10
  failureThreshold: 8
startupProbe:
  httpGet:
    path: {{ .contextPath }}/actuator/health
    port: {{ .port }}
  initialDelaySeconds: 60
  periodSeconds: 15
  timeoutSeconds: 10
  failureThreshold: 30
{{- end }}