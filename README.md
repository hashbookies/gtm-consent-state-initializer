# GTM Consent State Initializer

GTM tag template for initializing Consent Mode defaults before measurement tags run.

## Overview

GTM Consent State Initializer is a Google Tag Manager custom tag template that initializes Consent Mode defaults as early as possible using GTM consent APIs.

This template initializes Consent Mode defaults in GTM. It does not collect consent, create a consent banner, replace a CMP, or determine legal policy.

## What it does

- Sets default consent states through GTM consent APIs.
- Supports multiple default settings rows.
- Supports optional region-specific defaults.
- Supports `wait_for_update`.
- Optionally sets `ads_data_redaction`.
- Optionally sets `url_passthrough`.
- Optionally reads an existing JSON consent cookie and updates consent state.

## What it does not do

- It does not make a website compliant.
- It does not replace a CMP.
- It does not create a consent banner.
- It does not collect user consent.
- It does not determine legal policy.

## Supported consent types

- `ad_storage`
- `analytics_storage`
- `ad_user_data`
- `ad_personalization`
- `functionality_storage`
- `personalization_storage`
- `security_storage`

## Recommended trigger

Use with **Consent Initialization - All Pages** so defaults are established before measurement tags run.

## Configuration

### Default Settings

Each row can include:

- `Region`: optional comma-separated region codes such as `ES` or `US-CA`
- `Granted Consent Types`: comma-separated consent types to set as granted
- `Denied Consent Types`: comma-separated consent types to set as denied

### Wait For Update

Sets `wait_for_update` in milliseconds for each default state object.

Default:

```text
500
```

### Redact Ads Data

When enabled, sets `ads_data_redaction` using `gtagSet`.

### Pass Through URL Parameters

When enabled, sets `url_passthrough` using `gtagSet`.

### Read Existing Consent Cookie

When enabled, attempts to read a JSON consent cookie and update consent state with recognized consent values.

## Cookie format

The optional consent cookie is expected to contain JSON with GTM consent type keys.

Example:

```json
{
  "ad_storage": "granted",
  "analytics_storage": "denied",
  "ad_user_data": "denied",
  "ad_personalization": "denied"
}
```

Only `granted` and `denied` values are used.

## Testing guidance

1. Import the template into GTM.
2. Review the generated permissions carefully.
3. Create a tag using **GTM Consent State Initializer**.
4. Trigger it with **Consent Initialization - All Pages**.
5. Use GTM Preview mode and Tag Assistant to confirm consent defaults are set before measurement tags run.

## Limitations

- This template does not collect or store consent choices by itself.
- Cookie reading only works when a supported JSON cookie already exists.
- Consent configuration should be reviewed with appropriate legal and privacy stakeholders.
- GTM Template Editor permission review is required before production use.

## Maintainer

Created and maintained by Tayo Kolade.

This template is part of a small collection of independent open-source Google Tag Manager utilities for general measurement and reporting use cases.

## Disclaimer

This is an independent open-source utility created for general Google Tag Manager use cases. It is not affiliated with or endorsed by Google or any third-party platform provider.
