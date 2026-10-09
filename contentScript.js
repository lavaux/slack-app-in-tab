// Runs in the page's main world (see manifest.json) before Slack's own scripts.
// Slack always runs in app mode on Chrome OS, so pretend to be a recent Chrome OS.

// Chrome ships a new major version every 4 weeks. Derive the current one from
// the date so that Slack never sees an outdated browser. Stay one version behind
// to be sure it is already on the stable channel.
const FOUR_WEEKS = 28 * 24 * 3600 * 1000;
const CHROME_MAJOR =
  120 + Math.floor((Date.now() - Date.UTC(2023, 11, 5)) / FOUR_WEEKS) - 1;

const CHROMEOS_UAS = `Mozilla/5.0 (X11; CrOS x86_64 14541.0.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${CHROME_MAJOR}.0.0.0 Safari/537.36`;

const spoof = (name, value) =>
  Object.defineProperty(Navigator.prototype, name, {
    get: () => value,
    configurable: true,
  });

spoof("userAgent", CHROMEOS_UAS);
spoof("appVersion", CHROMEOS_UAS.replace(/^Mozilla\//, ""));
spoof("platform", "Linux x86_64");

// Chromium also exposes the platform through User-Agent Client Hints.
if ("userAgentData" in navigator) {
  const brands = [
    { brand: "Chromium", version: `${CHROME_MAJOR}` },
    { brand: "Google Chrome", version: `${CHROME_MAJOR}` },
    { brand: "Not-A.Brand", version: "99" },
  ];
  const lowEntropy = { brands, mobile: false, platform: "Chrome OS" };
  spoof("userAgentData", {
    ...lowEntropy,
    toJSON: () => lowEntropy,
    getHighEntropyValues: async () => ({
      ...lowEntropy,
      architecture: "x86",
      bitness: "64",
      model: "",
      platformVersion: "14541.0.0",
      uaFullVersion: `${CHROME_MAJOR}.0.0.0`,
      fullVersionList: brands.map((b) => ({ ...b, version: `${b.version}.0.0.0` })),
      wow64: false,
    }),
  });
}
