___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_tk_consent_state_initializer",
  "version": 1,
  "displayName": "GTM Consent State Initializer",
  "categories": [
    "TAG_MANAGEMENT",
    "UTILITY",
    "ANALYTICS"
  ],
  "description": "Initializes Consent Mode defaults as early as possible using GTM consent APIs.",
  "containerContexts": [
    "WEB"
  ],
  "securityGroups": []
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SIMPLE_TABLE",
    "name": "defaultSettings",
    "displayName": "Default Settings",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Region",
        "name": "region",
        "type": "TEXT",
        "valueHint": "ES,US-CA"
      },
      {
        "defaultValue": "",
        "displayName": "Granted Consent Types",
        "name": "granted",
        "type": "TEXT",
        "valueHint": "analytics_storage,security_storage"
      },
      {
        "defaultValue": "",
        "displayName": "Denied Consent Types",
        "name": "denied",
        "type": "TEXT",
        "valueHint": "ad_storage,ad_user_data,ad_personalization"
      }
    ],
    "help": "Define one or more consent default rows. Leave Region blank to apply the row globally."
  },
  {
    "type": "TEXT",
    "name": "waitForUpdate",
    "displayName": "Wait For Update (Milliseconds)",
    "simpleValueType": true,
    "defaultValue": "500",
    "help": "Used for asynchronous CMP updates. Applied as wait_for_update on each default state.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "adsDataRedaction",
    "checkboxText": "Redact Ads Data",
    "simpleValueType": true,
    "help": "Enable this to set ads_data_redaction using gtagSet."
  },
  {
    "type": "CHECKBOX",
    "name": "urlPassthrough",
    "checkboxText": "Pass Through URL Parameters",
    "simpleValueType": true,
    "help": "Enable this to set url_passthrough using gtagSet."
  },
  {
    "type": "CHECKBOX",
    "name": "readConsentCookie",
    "checkboxText": "Read Existing Consent Cookie",
    "simpleValueType": true,
    "help": "Enable this to read an existing consent cookie and update consent immediately if values are present."
  },
  {
    "type": "TEXT",
    "name": "consentCookieName",
    "displayName": "Consent Cookie Name",
    "simpleValueType": true,
    "help": "JSON cookie read when 'Read Existing Consent Cookie' is enabled.",
    "valueHint": "cmp_consent",
    "enablingConditions": [
      {
        "paramName": "readConsentCookie",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const setDefaultConsentState = require('setDefaultConsentState');
const updateConsentState = require('updateConsentState');
const gtagSet = require('gtagSet');
const getCookieValues = require('getCookieValues');
const getType = require('getType');
const makeString = require('makeString');
const makeNumber = require('makeNumber');
const JSON = require('JSON');

const VALID_CONSENT_TYPES = {
  ad_storage: true,
  analytics_storage: true,
  ad_user_data: true,
  ad_personalization: true,
  functionality_storage: true,
  personalization_storage: true,
  security_storage: true
};

const splitInput = function(input) {
  if (getType(input) !== 'string') return [];
  return makeString(input).split(',').map(function(entry) {
    return entry.trim();
  }).filter(function(entry) {
    return entry.length > 0;
  });
};

const parseDefaultRow = function(settings, waitForUpdate) {
  const commandData = {};
  const regions = splitInput(settings.region);
  const granted = splitInput(settings.granted);
  const denied = splitInput(settings.denied);

  if (regions.length > 0) {
    commandData.region = regions;
  }

  for (let i = 0; i < granted.length; i++) {
    if (VALID_CONSENT_TYPES[granted[i]]) {
      commandData[granted[i]] = 'granted';
    }
  }

  for (let i = 0; i < denied.length; i++) {
    if (VALID_CONSENT_TYPES[denied[i]]) {
      commandData[denied[i]] = 'denied';
    }
  }

  commandData.wait_for_update = waitForUpdate;
  return commandData;
};

const parseConsentCookie = function(cookieValue) {
  const parsed = JSON.parse(cookieValue);
  if (getType(parsed) !== 'object') return null;

  const consentState = {};
  const keys = [
    'ad_storage',
    'analytics_storage',
    'ad_user_data',
    'ad_personalization',
    'functionality_storage',
    'personalization_storage',
    'security_storage'
  ];

  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    const value = parsed[key];
    if (value === 'granted' || value === 'denied') {
      consentState[key] = value;
    }
  }

  return consentState;
};

const waitForUpdate = makeNumber(data.waitForUpdate);
const safeWaitForUpdate = waitForUpdate === waitForUpdate && waitForUpdate >= 0 ? waitForUpdate : 500;

gtagSet('ads_data_redaction', data.adsDataRedaction === true);
gtagSet('url_passthrough', data.urlPassthrough === true);

const defaultRows = getType(data.defaultSettings) === 'array' ? data.defaultSettings : [];
for (let i = 0; i < defaultRows.length; i++) {
  setDefaultConsentState(parseDefaultRow(defaultRows[i], safeWaitForUpdate));
}

if (data.readConsentCookie === true && getType(data.consentCookieName) === 'string') {
  const cookieName = makeString(data.consentCookieName);
  const cookieValues = getCookieValues(cookieName);
  if (getType(cookieValues) === 'array' && cookieValues.length > 0) {
    const consentState = parseConsentCookie(cookieValues[0]);
    if (consentState && getType(consentState) === 'object') {
      updateConsentState(consentState);
    }
  }
}

data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "ad_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "analytics_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "ad_user_data" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "ad_personalization" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "functionality_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "personalization_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "security_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "write_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              { "type": 1, "string": "ads_data_redaction" },
              { "type": 1, "string": "url_passthrough" }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": []
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": false
  }
]


___TESTS___

scenarios: []


___NOTES___

Community-ready template for initializing GTM Consent Mode defaults.
