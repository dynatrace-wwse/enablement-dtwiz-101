# Resources

- [dtwiz on GitHub (dynatrace-oss/dtwiz)](https://github.com/dynatrace-oss/dtwiz) — source, README, releases
- [dtwiz install script](https://raw.githubusercontent.com/dynatrace-oss/dtwiz/main/scripts/install.sh) — the one-liner used in Section 01
- [Dynatrace platform tokens](https://docs.dynatrace.com/docs/manage/identity-access-management/access-tokens-and-oauth-clients/platform-tokens) — the modern `dt0s16` token dtwiz reads from `DT_PLATFORM_TOKEN` (classic `dt0c01` tokens are being deprecated)
- [OpenTelemetry + Dynatrace](https://docs.dynatrace.com/docs/extend-dynatrace/opentelemetry) — how the schnitzel demo's OTLP spans reach your tenant as first-class Grail records
- [Dynatrace Query Language (DQL)](https://docs.dynatrace.com/docs/discover-dynatrace/platform/grail/dynatrace-query-language) — the `fetch spans` query language used to read the demo's OpenTelemetry data
