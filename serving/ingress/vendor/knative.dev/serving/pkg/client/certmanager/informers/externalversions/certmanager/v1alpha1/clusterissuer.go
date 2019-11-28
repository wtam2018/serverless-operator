/*
Copyright 2019 The Knative Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by informer-gen. DO NOT EDIT.

package v1alpha1

import (
	time "time"

	certmanagerv1alpha1 "github.com/jetstack/cert-manager/pkg/apis/certmanager/v1alpha1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
	watch "k8s.io/apimachinery/pkg/watch"
	cache "k8s.io/client-go/tools/cache"
	versioned "knative.dev/serving/pkg/client/certmanager/clientset/versioned"
	internalinterfaces "knative.dev/serving/pkg/client/certmanager/informers/externalversions/internalinterfaces"
	v1alpha1 "knative.dev/serving/pkg/client/certmanager/listers/certmanager/v1alpha1"
)

// ClusterIssuerInformer provides access to a shared informer and lister for
// ClusterIssuers.
type ClusterIssuerInformer interface {
	Informer() cache.SharedIndexInformer
	Lister() v1alpha1.ClusterIssuerLister
}

type clusterIssuerInformer struct {
	factory          internalinterfaces.SharedInformerFactory
	tweakListOptions internalinterfaces.TweakListOptionsFunc
}

// NewClusterIssuerInformer constructs a new informer for ClusterIssuer type.
// Always prefer using an informer factory to get a shared informer instead of getting an independent
// one. This reduces memory footprint and number of connections to the server.
func NewClusterIssuerInformer(client versioned.Interface, resyncPeriod time.Duration, indexers cache.Indexers) cache.SharedIndexInformer {
	return NewFilteredClusterIssuerInformer(client, resyncPeriod, indexers, nil)
}

// NewFilteredClusterIssuerInformer constructs a new informer for ClusterIssuer type.
// Always prefer using an informer factory to get a shared informer instead of getting an independent
// one. This reduces memory footprint and number of connections to the server.
func NewFilteredClusterIssuerInformer(client versioned.Interface, resyncPeriod time.Duration, indexers cache.Indexers, tweakListOptions internalinterfaces.TweakListOptionsFunc) cache.SharedIndexInformer {
	return cache.NewSharedIndexInformer(
		&cache.ListWatch{
			ListFunc: func(options v1.ListOptions) (runtime.Object, error) {
				if tweakListOptions != nil {
					tweakListOptions(&options)
				}
				return client.CertmanagerV1alpha1().ClusterIssuers().List(options)
			},
			WatchFunc: func(options v1.ListOptions) (watch.Interface, error) {
				if tweakListOptions != nil {
					tweakListOptions(&options)
				}
				return client.CertmanagerV1alpha1().ClusterIssuers().Watch(options)
			},
		},
		&certmanagerv1alpha1.ClusterIssuer{},
		resyncPeriod,
		indexers,
	)
}

func (f *clusterIssuerInformer) defaultInformer(client versioned.Interface, resyncPeriod time.Duration) cache.SharedIndexInformer {
	return NewFilteredClusterIssuerInformer(client, resyncPeriod, cache.Indexers{cache.NamespaceIndex: cache.MetaNamespaceIndexFunc}, f.tweakListOptions)
}

func (f *clusterIssuerInformer) Informer() cache.SharedIndexInformer {
	return f.factory.InformerFor(&certmanagerv1alpha1.ClusterIssuer{}, f.defaultInformer)
}

func (f *clusterIssuerInformer) Lister() v1alpha1.ClusterIssuerLister {
	return v1alpha1.NewClusterIssuerLister(f.Informer().GetIndexer())
}