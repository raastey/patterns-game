#!/usr/bin/env python3
"""Push Pattern Path (The Pattern Game) App Store Connect metadata via API. Does not submit for review."""
from __future__ import annotations

import importlib.util
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUNDLE_ID = "fun.raastey.patternpath"
LOCALE = "en-US"
REVIEW_CONTACT_PHONE = "+19176050642"
CONTENT_RIGHTS_DECLARATION = "DOES_NOT_USE_THIRD_PARTY_CONTENT"
PRIMARY_CATEGORY_ID = "EDUCATION"
SECONDARY_CATEGORY_ID = "GAMES"
TARGET_PRICE = "1.99"
BASE_TERRITORY = "USA"

_meta_path = ROOT / "docs" / "ios-app-store" / "metadata-content.py"
_spec = importlib.util.spec_from_file_location("metadata_content", _meta_path)
_meta = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(_meta)

PRIVACY_URL = _meta.PRIVACY_URL
SUPPORT_URL = _meta.SUPPORT_URL
MARKETING_URL = _meta.MARKETING_URL
SUBTITLE = _meta.SUBTITLE
COPYRIGHT = _meta.COPYRIGHT
PROMOTIONAL_TEXT = _meta.PROMOTIONAL_TEXT
KEYWORDS = _meta.KEYWORDS
WHATS_NEW = _meta.WHATS_NEW
DESCRIPTION = _meta.DESCRIPTION
REVIEW_NOTES = _meta.REVIEW_NOTES

PUBLIC_METADATA_FIELDS = {
    "subtitle": SUBTITLE,
    "promotional text": PROMOTIONAL_TEXT,
    "keywords": KEYWORDS,
    "description": DESCRIPTION,
    "what's new": WHATS_NEW,
}
APPLE_PRODUCT_TERMS = (
    "iphone",
    "ipad",
    "ipod",
    "apple",
    "proraw",
    "action button",
    "camera control",
    "lock screen",
    "control center",
)
STORE_VERSION = "1.0.0"
LATEST_BUILD_NUMBER = "2"
RELEASE_TYPE = "MANUAL"

AGE_RATING_ATTRIBUTES = {
    "advertising": False,
    "ageAssurance": False,
    "alcoholTobaccoOrDrugUseOrReferences": "NONE",
    "contests": "NONE",
    "gambling": False,
    "gamblingSimulated": "NONE",
    "gunsOrOtherWeapons": "NONE",
    "healthOrWellnessTopics": False,
    "lootBox": False,
    "medicalOrTreatmentInformation": "NONE",
    "messagingAndChat": False,
    "parentalControls": False,
    "profanityOrCrudeHumor": "NONE",
    "sexualContentGraphicAndNudity": "NONE",
    "sexualContentOrNudity": "NONE",
    "horrorOrFearThemes": "NONE",
    "matureOrSuggestiveThemes": "NONE",
    "unrestrictedWebAccess": False,
    "userGeneratedContent": False,
    "violenceCartoonOrFantasy": "NONE",
    "violenceRealisticProlongedGraphicOrSadistic": "NONE",
    "violenceRealistic": "NONE",
}


def load_env() -> None:
    env_path = ROOT / "asc.env"
    if not env_path.exists():
        return
    for line in env_path.read_text().splitlines():
        line = line.strip().rstrip("\r")
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        os.environ.setdefault(key.strip(), value.strip())


def jwt_token() -> str:
    try:
        import jwt
    except ImportError:
        raise SystemExit("PyJWT required: pip install PyJWT cryptography")

    key_path = os.environ.get("ASC_KEY_PATH") or str(ROOT / f"AuthKey_{os.environ['ASC_KEY_ID']}.p8")
    with open(key_path) as f:
        private_key = f.read()
    return jwt.encode(
        {
            "iss": os.environ["ASC_ISSUER_ID"],
            "exp": int(time.time()) + 1200,
            "aud": "appstoreconnect-v1",
        },
        private_key,
        algorithm="ES256",
        headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"},
    )


class Client:
    def __init__(self, token: str) -> None:
        self.token = token

    def request(self, method: str, url: str, body: dict | None = None) -> tuple[int, dict]:
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(
            url,
            data=data,
            method=method,
            headers={
                "Authorization": f"Bearer {self.token}",
                "Content-Type": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(req) as resp:
                raw = resp.read()
                return resp.status, json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            raw = e.read()
            try:
                payload = json.loads(raw)
            except json.JSONDecodeError:
                payload = {"raw": raw.decode(errors="replace")}
            return e.code, payload


def set_price(client: Client, app_id: str) -> None:
    code, data = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/appPricePoints"
        f"?filter[territory]={BASE_TERRITORY}&limit=200",
    )
    if code != 200:
        print(f"price points failed: {code}", json.dumps(data, indent=2))
        return
    pp_id = None
    for item in data.get("data", []):
        if item.get("attributes", {}).get("customerPrice") == TARGET_PRICE:
            pp_id = item["id"]
            break
    if not pp_id:
        print(f"WARNING: no ${TARGET_PRICE} price point found")
        return
    body = {
        "data": {
            "type": "appPriceSchedules",
            "relationships": {
                "app": {"data": {"type": "apps", "id": app_id}},
                "baseTerritory": {"data": {"type": "territories", "id": BASE_TERRITORY}},
                "manualPrices": {"data": [{"type": "appPrices", "id": "${price1}"}]},
            },
        },
        "included": [
            {
                "id": "${price1}",
                "type": "appPrices",
                "attributes": {"startDate": None},
                "relationships": {
                    "appPricePoint": {"data": {"type": "appPricePoints", "id": pp_id}}
                },
            }
        ],
    }
    code, resp = client.request("POST", "https://api.appstoreconnect.apple.com/v1/appPriceSchedules", body)
    print(f"price schedule POST ${TARGET_PRICE}: {code}", "OK" if code in (200, 201) else json.dumps(resp, indent=2))


def main() -> int:
    load_env()
    if not os.environ.get("ASC_KEY_ID") or not os.environ.get("ASC_ISSUER_ID"):
        print("Missing ASC_KEY_ID or ASC_ISSUER_ID in asc.env", file=sys.stderr)
        return 1

    violations = [
        f"{field} contains Apple product term {term!r}"
        for field, value in PUBLIC_METADATA_FIELDS.items()
        for term in APPLE_PRODUCT_TERMS
        if term in value.lower()
    ]
    emdash_hits = [
        f"{field} contains em-dash"
        for field, value in PUBLIC_METADATA_FIELDS.items()
        if "\u2014" in value or "\u2013" in value
    ]
    violations.extend(emdash_hits)
    if violations:
        print("Refusing to publish trademark-risky public metadata:", *violations, sep="\n", file=sys.stderr)
        return 1

    if len(SUBTITLE) > 30:
        print(f"subtitle exceeds 30 chars ({len(SUBTITLE)})", file=sys.stderr)
        return 1
    if len(PROMOTIONAL_TEXT) > 170:
        print(f"promotional text exceeds 170 chars ({len(PROMOTIONAL_TEXT)})", file=sys.stderr)
        return 1
    if len(KEYWORDS) > 100:
        print(f"keywords exceed 100 chars ({len(KEYWORDS)})", file=sys.stderr)
        return 1
    if len(DESCRIPTION) > 4000:
        print(f"description exceeds 4000 chars ({len(DESCRIPTION)})", file=sys.stderr)
        return 1

    client = Client(jwt_token())

    code, apps = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/apps?filter[bundleId]={BUNDLE_ID}&limit=1",
    )
    if code != 200 or not apps.get("data"):
        print("App not found:", code, json.dumps(apps, indent=2))
        return 1
    app_id = apps["data"][0]["id"]
    print(f"App id: {app_id}")

    code, patched_app = client.request(
        "PATCH",
        f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}",
        {
            "data": {
                "type": "apps",
                "id": app_id,
                "attributes": {"contentRightsDeclaration": CONTENT_RIGHTS_DECLARATION},
            }
        },
    )
    print(
        f"app contentRights PATCH: {code}",
        json.dumps(patched_app, indent=2) if code != 200 else "OK",
    )

    code, infos = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/appInfos?limit=10",
    )
    if code != 200:
        print("appInfos failed:", code, json.dumps(infos, indent=2))
        return 1

    app_info_id = None
    for item in infos.get("data", []):
        if item.get("attributes", {}).get("locale") == LOCALE:
            app_info_id = item["id"]
            break
    if not app_info_id and infos.get("data"):
        app_info_id = infos["data"][0]["id"]

    if app_info_id:
        relationships = {
            "primaryCategory": {
                "data": {"type": "appCategories", "id": PRIMARY_CATEGORY_ID}
            }
        }
        if SECONDARY_CATEGORY_ID:
            relationships["secondaryCategory"] = {
                "data": {"type": "appCategories", "id": SECONDARY_CATEGORY_ID}
            }
        code, cat_patch = client.request(
            "PATCH",
            f"https://api.appstoreconnect.apple.com/v1/appInfos/{app_info_id}",
            {
                "data": {
                    "type": "appInfos",
                    "id": app_info_id,
                    "relationships": relationships,
                }
            },
        )
        print(f"category PATCH: {code}", "OK" if code == 200 else json.dumps(cat_patch, indent=2))

        code, info_locs = client.request(
            "GET",
            f"https://api.appstoreconnect.apple.com/v1/appInfos/{app_info_id}/appInfoLocalizations",
        )
        if code == 200 and info_locs.get("data"):
            info_loc_id = None
            for item in info_locs["data"]:
                if item.get("attributes", {}).get("locale") == LOCALE:
                    info_loc_id = item["id"]
                    break
            if not info_loc_id:
                info_loc_id = info_locs["data"][0]["id"]
            code, patched = client.request(
                "PATCH",
                f"https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{info_loc_id}",
                {
                    "data": {
                        "type": "appInfoLocalizations",
                        "id": info_loc_id,
                        "attributes": {
                            "subtitle": SUBTITLE,
                            "privacyPolicyUrl": PRIVACY_URL,
                        },
                    }
                },
            )
            print(
                f"appInfoLocalization PATCH: {code}",
                json.dumps(patched, indent=2) if code != 200 else "OK",
            )
        else:
            print("appInfoLocalizations failed:", code, json.dumps(info_locs, indent=2))

    code, versions = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&limit=5",
    )
    if code != 200 or not versions.get("data"):
        print("versions failed:", code, json.dumps(versions, indent=2))
        return 1

    version_id = versions["data"][0]["id"]
    version_attrs = versions["data"][0].get("attributes", {})
    print(f"Version id: {version_id} state={version_attrs.get('appStoreState')} ver={version_attrs.get('versionString')}")

    ver_attrs: dict = {
        "copyright": COPYRIGHT,
        "releaseType": RELEASE_TYPE,
        "usesIdfa": False,
    }
    if version_attrs.get("versionString") != STORE_VERSION:
        ver_attrs["versionString"] = STORE_VERSION
        print(f"Aligning store version {version_attrs.get('versionString')} -> {STORE_VERSION}")
    code, patched_ver = client.request(
        "PATCH",
        f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}",
        {
            "data": {
                "type": "appStoreVersions",
                "id": version_id,
                "attributes": ver_attrs,
            }
        },
    )
    print(f"version PATCH: {code}", json.dumps(patched_ver, indent=2) if code != 200 else "OK")

    code, builds = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/builds?filter[app]={app_id}&sort=-uploadedDate&limit=10&include=preReleaseVersion",
    )
    attach_id = None
    if code == 200:
        for b in builds.get("data", []):
            if b.get("attributes", {}).get("processingState") != "VALID":
                continue
            if b.get("attributes", {}).get("expired"):
                continue
            if str(b.get("attributes", {}).get("version")) == LATEST_BUILD_NUMBER:
                attach_id = b["id"]
                break
        if not attach_id and builds.get("data"):
            for b in builds["data"]:
                if b.get("attributes", {}).get("processingState") == "VALID" and not b.get("attributes", {}).get("expired"):
                    attach_id = b["id"]
                    print(f"WARNING: attaching newest VALID build {b['attributes'].get('version')} (wanted {LATEST_BUILD_NUMBER})")
                    break
    if attach_id:
        code, _ = client.request(
            "PATCH",
            f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/relationships/build",
            {"data": {"type": "builds", "id": attach_id}},
        )
        print(f"build attach PATCH: {code}", "OK" if code in (200, 204) else _)
    else:
        print("WARNING: no VALID build found to attach (icon stays placeholder until upload)")

    code, locs = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations",
    )
    if code != 200:
        print("localizations failed:", code, json.dumps(locs, indent=2))
        return 1

    loc_id = None
    for item in locs.get("data", []):
        if item.get("attributes", {}).get("locale") == LOCALE:
            loc_id = item["id"]
            break
    if not loc_id and locs.get("data"):
        loc_id = locs["data"][0]["id"]

    if loc_id:
        loc_attrs = {
            "description": DESCRIPTION,
            "keywords": KEYWORDS,
            "promotionalText": PROMOTIONAL_TEXT,
            "supportUrl": SUPPORT_URL,
            "marketingUrl": MARKETING_URL,
            "whatsNew": WHATS_NEW,
        }
        code, patched_loc = client.request(
            "PATCH",
            f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc_id}",
            {
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "id": loc_id,
                    "attributes": loc_attrs,
                }
            },
        )
        if code == 409 and "whatsNew" in loc_attrs:
            loc_attrs.pop("whatsNew")
            code, patched_loc = client.request(
                "PATCH",
                f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc_id}",
                {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": loc_id,
                        "attributes": loc_attrs,
                    }
                },
            )
            print("localization retry without locked whatsNew")
        print(f"localization PATCH: {code}", json.dumps(patched_loc, indent=2) if code != 200 else "OK")

    code, detail = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{version_id}/appStoreReviewDetail",
    )
    if code == 200 and detail.get("data"):
        detail_id = detail["data"]["id"]
        code, patched_detail = client.request(
            "PATCH",
            f"https://api.appstoreconnect.apple.com/v1/appStoreReviewDetails/{detail_id}",
            {
                "data": {
                    "type": "appStoreReviewDetails",
                    "id": detail_id,
                    "attributes": {
                        "notes": REVIEW_NOTES,
                        "contactEmail": "hello@sixtwelve.studio",
                        "contactFirstName": "Zeeshan",
                        "contactLastName": "Khan",
                        "contactPhone": REVIEW_CONTACT_PHONE,
                        "demoAccountRequired": False,
                    },
                }
            },
        )
        print(f"review detail PATCH: {code}", json.dumps(patched_detail, indent=2) if code != 200 else "OK")
    else:
        code, created = client.request(
            "POST",
            "https://api.appstoreconnect.apple.com/v1/appStoreReviewDetails",
            {
                "data": {
                    "type": "appStoreReviewDetails",
                    "attributes": {
                        "notes": REVIEW_NOTES,
                        "contactEmail": "hello@sixtwelve.studio",
                        "contactFirstName": "Zeeshan",
                        "contactLastName": "Khan",
                        "contactPhone": REVIEW_CONTACT_PHONE,
                        "demoAccountRequired": False,
                    },
                    "relationships": {
                        "appStoreVersion": {
                            "data": {"type": "appStoreVersions", "id": version_id}
                        }
                    },
                }
            },
        )
        print(f"review detail POST: {code}", json.dumps(created, indent=2) if code not in (200, 201) else "OK")

    if app_info_id:
        code, age_decl = client.request(
            "GET",
            f"https://api.appstoreconnect.apple.com/v1/appInfos/{app_info_id}/ageRatingDeclaration",
        )
        if code == 200 and age_decl.get("data"):
            age_decl_id = age_decl["data"]["id"]
            code, patched_age = client.request(
                "PATCH",
                f"https://api.appstoreconnect.apple.com/v1/ageRatingDeclarations/{age_decl_id}",
                {
                    "data": {
                        "type": "ageRatingDeclarations",
                        "id": age_decl_id,
                        "attributes": AGE_RATING_ATTRIBUTES,
                    }
                },
            )
            print(
                f"age rating PATCH: {code}",
                json.dumps(patched_age, indent=2) if code != 200 else "OK (4+)",
            )
        else:
            print("age rating GET failed:", code, json.dumps(age_decl, indent=2))

    set_price(client, app_id)
    ensure_worldwide_availability(client, app_id)
    ensure_beta_metadata(client, app_id)

    print("Done. Screenshots, App Privacy, build attach, and live legal URLs still need attention before Add for Review.")
    return 0


def ensure_worldwide_availability(client: Client, app_id: str) -> None:
    code, existing = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/appAvailabilityV2",
    )
    if code == 200 and existing.get("data"):
        code, territories = client.request(
            "GET",
            f"https://api.appstoreconnect.apple.com/v2/appAvailabilities/{app_id}/territoryAvailabilities?limit=200",
        )
        total = ((territories.get("meta") or {}).get("paging") or {}).get("total")
        available = sum(
            1
            for item in territories.get("data", [])
            if item.get("attributes", {}).get("available")
        )
        print(f"availability already set: {available}/{total or len(territories.get('data', []))} territories")
        return

    territories: list[str] = []
    url: str | None = "https://api.appstoreconnect.apple.com/v1/territories?limit=200"
    while url:
        code, data = client.request("GET", url)
        if code != 200:
            print(f"territories failed: {code}", json.dumps(data, indent=2))
            return
        territories.extend(item["id"] for item in data.get("data", []))
        url = (data.get("links") or {}).get("next")

    included = [
        {
            "type": "territoryAvailabilities",
            "id": f"${{{code}}}",
            "attributes": {"available": True},
            "relationships": {
                "territory": {"data": {"type": "territories", "id": code}}
            },
        }
        for code in territories
    ]
    body = {
        "data": {
            "type": "appAvailabilities",
            "attributes": {"availableInNewTerritories": True},
            "relationships": {
                "app": {"data": {"type": "apps", "id": app_id}},
                "territoryAvailabilities": {
                    "data": [
                        {"type": "territoryAvailabilities", "id": f"${{{code}}}"}
                        for code in territories
                    ]
                },
            },
        },
        "included": included,
    }
    code, resp = client.request(
        "POST", "https://api.appstoreconnect.apple.com/v2/appAvailabilities", body
    )
    print(
        f"availability POST ({len(territories)} territories): {code}",
        "OK" if code in (200, 201) else json.dumps(resp, indent=2),
    )


def ensure_beta_metadata(client: Client, app_id: str) -> None:
    code, patched = client.request(
        "PATCH",
        f"https://api.appstoreconnect.apple.com/v1/betaAppReviewDetails/{app_id}",
        {
            "data": {
                "type": "betaAppReviewDetails",
                "id": app_id,
                "attributes": {
                    "contactFirstName": "Zeeshan",
                    "contactLastName": "Khan",
                    "contactPhone": REVIEW_CONTACT_PHONE,
                    "contactEmail": "hello@sixtwelve.studio",
                    "demoAccountRequired": False,
                    "notes": REVIEW_NOTES,
                },
            }
        },
    )
    print(
        f"betaAppReviewDetail PATCH: {code}",
        json.dumps(patched, indent=2) if code != 200 else "OK",
    )

    code, locs = client.request(
        "GET",
        f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/betaAppLocalizations",
    )
    beta_loc_id = None
    if code == 200:
        for item in locs.get("data", []):
            if item.get("attributes", {}).get("locale") == LOCALE:
                beta_loc_id = item["id"]
                break
    beta_attrs = {
        "description": DESCRIPTION,
        "feedbackEmail": "hello@sixtwelve.studio",
        "marketingUrl": MARKETING_URL,
        "privacyPolicyUrl": PRIVACY_URL,
    }
    if beta_loc_id:
        code, patched = client.request(
            "PATCH",
            f"https://api.appstoreconnect.apple.com/v1/betaAppLocalizations/{beta_loc_id}",
            {
                "data": {
                    "type": "betaAppLocalizations",
                    "id": beta_loc_id,
                    "attributes": beta_attrs,
                }
            },
        )
        print(
            f"betaAppLocalization PATCH: {code}",
            json.dumps(patched, indent=2) if code != 200 else "OK",
        )
    else:
        code, created = client.request(
            "POST",
            "https://api.appstoreconnect.apple.com/v1/betaAppLocalizations",
            {
                "data": {
                    "type": "betaAppLocalizations",
                    "attributes": {"locale": LOCALE, **beta_attrs},
                    "relationships": {
                        "app": {"data": {"type": "apps", "id": app_id}}
                    },
                }
            },
        )
        print(
            f"betaAppLocalization POST: {code}",
            json.dumps(created, indent=2) if code not in (200, 201) else "OK",
        )


if __name__ == "__main__":
    raise SystemExit(main())
