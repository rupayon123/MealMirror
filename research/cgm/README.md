# Historical CGM CSV import research prototype

Status: **research only, not in the MealMirror app or Challenge ZIP**. Reviewed October 4, 2026. The parser and probe contain only synthetic rows and no patient data.

## Why this route is viable, and its limit

- [Dexcom Clarity's user guide](https://productstore.clarity.dexcom.com/Documentation/en/Dexcom_Clarity_User_Guide_Home_User.pdf) documents a person-initiated CSV export of raw glucose values, calibrations, and events. Its safety statement says Clarity data is older than the real-time CGM display and must not drive treatment decisions.
- [Abbott's Libre 3 FAQ](https://www.support.freestyle.abbott/hc/en-us/articles/14806679954199-Can-I-download-my-data-with-the-FreeStyle-Libre-3-app) directs people to download raw glucose data from LibreView's **Glucose History → Download Glucose Data**. Abbott describes LibreView data as historical and says it is not for treatment decisions.
- Both vendors require the person to obtain an export from their cloud service first. Parsing an already exported, user-selected file can happen offline. This is not live CGM access or a direct API integration.
- [A University of Michigan export comparison](https://teamdynamix.umich.edu/TDClient/210/DepressionCenter/Questions/Details/100073) publishes observed Dexcom Clarity and LibreView patient CSV headers and example rows. These are observations of specific exports, not a vendor schema guarantee. We did not copy the real person's readings or identifiers into fixtures.

## Scope of the prototype

`HistoricalCSVPrototype.swift` accepts UTF-8 CSV up to 25 MiB, including quoted fields, CRLF, and a UTF-8 BOM. It recognizes only:

| Source | Examined layout | Imported records |
| --- | --- | --- |
| Dexcom Clarity | English `Index`, `Timestamp (YYYY-MM-DDThh:mm:ss)`, `Event Type`, `Glucose Value (mg/dL)` columns | Numeric `EGV` rows only; `High`/`Low` are counted but not turned into invented values |
| LibreView | Patient `Glucose Data` metadata row, followed by `Device Timestamp`, `Record Type`, and explicit `Historic Glucose mg/dL` or `Historic Glucose mmol/L` | Numeric type `0` historical rows only; scan, strip, food, insulin, and note rows are not counted as CGM points |

The result holds source, value, explicit unit, and the export's **device-local timestamp string**. It does not produce an absolute `Date`, convert units, fill gaps, infer missing readings, calculate glucose trends, match readings to meals, or recommend insulin. Unknown formats, malformed rows, unlabeled units, unexpected numeric text, and provider-side `Patient report` exports fail as a whole.

The [University of Michigan comparison](https://teamdynamix.umich.edu/TDClient/210/DepressionCenter/Questions/Details/100073) shows a LibreView provider export can add a name and date-of-birth row. Patient exports may still contain names, serial numbers, insulin events, and free-text notes. The prototype returns none of those fields and never logs a row. A future app importer must keep the selected file on device, avoid analytics/backup leakage, offer deletion, and clearly explain what is retained.

## Important unresolved format and time issues

1. Neither vendor publishes a stable CSV schema in the reviewed public user documentation. Validate at least one current, consented, **de-identified** patient export from each vendor, plus mg/dL and mmol/L LibreView variants, before calling this compatible. Test localized header/decimal variants separately.
2. The observed timestamps have no UTC offset or named timezone. A date such as `4/12/2023 14:30` is ambiguous across locales and daylight-saving transitions. Do not compare it with a meal's absolute time, call it fresh, or draw a meal-response timeline until the export's clock semantics are established. The LibreView metadata's generated-at UTC stamp does not establish the device timestamp's timezone.
3. LibreView exports from newer and older devices may differ in cadence and included columns. The parser makes no cadence assumption. A record-type code beyond `0` is ignored, not reinterpreted.
4. Exported files may contain sensitive health data and identifiers. [Abbott's privacy notice](https://www.libreview.com/files/documents/en-US/unified-PP_2026-04-01.html) describes the export function as a way to receive or transfer a machine-readable copy where accessible. Its [individual user terms](https://www2.libreview.com/files/documents/en-US/pat-TOU_2025-06-17.html) require consent or guardian authority for another person's data and expressly discuss a person's choice to share data with third-party apps. The separate [professional terms](https://www2.libreview.com/files/documents/en-US/pro-TOU_2025-06-17.html) include restrictions on downloading patient data for display in unaffiliated third-party apps. This prototype rejects professional `Patient report` files. These documents are not a license to redistribute another person's export, a promise that every region exposes the same format, or permission to use undocumented APIs. Dexcom's [Clarity guide](https://productstore.clarity.dexcom.com/Documentation/en/Dexcom_Clarity_User_Guide_Home_User.pdf) says service use is subject to its terms. Do not place real exports in the repository or ask users to send raw CSV by chat.

## Reproduce the synthetic checks

```sh
swiftc research/cgm/HistoricalCSVPrototype.swift research/cgm/ImportProbe.swift -o /tmp/meal-cgm-probe
/tmp/meal-cgm-probe
```

The current 16-check probe covers both source layouts, mg/dL and mmol/L labeling, non-glucose row filtering, censored Dexcom values, quoted and multiline metadata, a UTF-8 BOM, rejected provider/unknown/duplicate headers, malformed CSV/row/timestamp, and invalid numeric readings. Synthetic checks establish parser behavior only; they do not validate vendor compatibility or clinical use.

**Next gate:** obtain current, consented exports on the user's own Mac and strip names, date of birth, serial/device IDs, free-text notes, and actual readings before sharing a minimal fixture for compatibility review. Retain header order, quoting, one anonymized glucose row, and the account locale/unit setting. Then decide whether a genuinely useful, safe historical view belongs in the app after the Challenge core is fully verified.
