// Copyright 2020 Lingfei Kong <colin404@foxmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package v1

import (
	"github.com/marmotedu/component-base/pkg/json"
	metav1 "github.com/marmotedu/component-base/pkg/meta/v1"
	"github.com/ory/ladon"
	"gorm.io/gorm"
)

// Policy represents a policy restful resource, include a ladon policy.
// It is also used as gorm model.
type Policy struct {
	// May add TypeMeta in the future.
	// metav1.TypeMeta `json:",inline"`

	// Standard object's metadata.
	metav1.ObjectMeta `json:"metadata,omitempty"`

	// The user of the policy.
	Username string `json:"username" gorm:"column:username" validate:"omitempty"`

	// The ladon policy content. Just a string format of ladon.DefaultPolicy
	PolicyStr string `json:"-" gorm:"column:policy" validate:"omitempty"`

	// Ladon policy, will not be stored.
	Policy ladon.DefaultPolicy `json:"policy,omitempty" gorm:"-" validate:"omitempty"`
}

// PolicyList is the whole list of all policies which have been stored in stroage.
type PolicyList struct {
	// May add TypeMeta in the future.
	// metav1.TypeMeta `json:",inline"`

	// Standard list metadata.
	metav1.ListMeta `json:",inline"`

	// List of policies.
	Items []*Policy `json:"items"`
}

// TableName maps to mysql table name.
func (p *Policy) TableName() string {
	return "policy"
}

// BeforeCreate run before create database record.
func (p *Policy) BeforeCreate(tx *gorm.DB) (err error) {
	ladon, err := json.Marshal(p.Policy)
	if err != nil {
		return err
	}

	p.PolicyStr = string(ladon)

	return
}

// BeforeUpdate run before update database record.
func (p *Policy) BeforeUpdate(tx *gorm.DB) (err error) {
	ladon, err := json.Marshal(p.Policy)
	if err != nil {
		return err
	}

	p.PolicyStr = string(ladon)

	return
}

// AfterFind run after find to unmarshal a policy string into ladon.DefaultPolicy struct.
func (p *Policy) AfterFind(tx *gorm.DB) (err error) {
	var policy ladon.DefaultPolicy
	if err := json.Unmarshal([]byte(p.PolicyStr), &policy); err != nil {
		return err
	}

	p.Policy = policy

	return
}
