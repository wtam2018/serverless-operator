#!/usr/bin/env bash

DIR=$(cd $(dirname "$0")/.. && pwd)
CRD_DIR=$DIR/.crds              # scratch dir

OLM_DIR=${OLM_DIR:-$DIR/olm-catalog}
NAME=${NAME:-$(ls $OLM_DIR)}

x=( $(echo $NAME | tr '-' ' ') )
DISPLAYNAME=${DISPLAYNAME:=${x[*]^}}

indent() {
  INDENT="      "
  ENDASH="    - "
  sed "s/^/$INDENT/" | sed "s/^${INDENT}\($1\)/${ENDASH}\1/"
}

# initialize scratch dir
rm -rf $CRD_DIR
mkdir $CRD_DIR

# deal with identical CRD's in nested dirs: highest version wins
find $OLM_DIR -name '*_crd.yaml' | sort -n | xargs -I{} cp {} $CRD_DIR/

# Determine if we're running locally or in CI.
if [ -n "$OPENSHIFT_BUILD_NAMESPACE" ]; then
  export IMAGE_KNATIVE_SERVING_OPERATOR="registry.svc.ci.openshift.org/${OPENSHIFT_BUILD_NAMESPACE}/stable:knative-serving-operator"
  export IMAGE_KNATIVE_OPENSHIFT_INGRESS="registry.svc.ci.openshift.org/${OPENSHIFT_BUILD_NAMESPACE}/stable:knative-openshift-ingress"
elif [ -n "$DOCKER_REPO_OVERRIDE" ]; then
  export IMAGE_KNATIVE_SERVING_OPERATOR="${DOCKER_REPO_OVERRIDE}/knative-serving-operator"
  export IMAGE_KNATIVE_OPENSHIFT_INGRESS="${DOCKER_REPO_OVERRIDE}/knative-openshift-ingress"
else
  export IMAGE_KNATIVE_SERVING_OPERATOR="registry.svc.ci.openshift.org/openshift/openshift-serverless-v1.3.0:knative-serving-operator"
  export IMAGE_KNATIVE_OPENSHIFT_INGRESS="registry.svc.ci.openshift.org/openshift/openshift-serverless-v1.3.0:knative-openshift-ingress"
fi

CRD=$(cat $(ls $CRD_DIR/*) | grep -v -- "---" | indent apiVersion)
CSV=$(cat $(find $OLM_DIR -name '*version.yaml' | sort -n) | envsubst | indent apiVersion)
PKG=$(cat $OLM_DIR/$NAME/*package.yaml | indent packageName)

cat <<EOF | sed 's/^  *$//'
kind: ConfigMap
apiVersion: v1
metadata:
  name: $NAME

data:
  customResourceDefinitions: |-
$CRD
  clusterServiceVersions: |-
$CSV
  packages: |-
$PKG
---
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: $NAME
spec:
  configMap: $NAME
  displayName: $DISPLAYNAME
  publisher: Red Hat
  sourceType: internal
EOF
