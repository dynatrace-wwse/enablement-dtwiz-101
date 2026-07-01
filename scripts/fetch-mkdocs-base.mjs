import { writeFileSync, existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

const baseYamlPath = join(import.meta.dirname, "../mkdocs-base.yaml");
if (!existsSync(baseYamlPath)) {
  console.log("Downloading mkdocs-base.yaml...");
  const shellScriptPath = join(import.meta.dirname, "../.devcontainer/util/source_framework.sh");
  let version = "1.4.0";
  try {
    const content = readFileSync(shellScriptPath, "utf8");
    const match = content.match(/FRAMEWORK_VERSION=["']([^"']+)["']/);
    if (match) {
      const rawVersion = match[1];
      if (rawVersion.includes(":-")) {
        const defaultMatch = rawVersion.match(/:-(.+)}/);
        if (defaultMatch) {
          version = defaultMatch[1];
        }
      } else {
        version = rawVersion;
      }
    }
  } catch (err) {
    console.warn(
      "Could not read framework version from source_framework.sh, defaulting to 1.4.0:",
      err.message
    );
  }

  const url = `https://raw.githubusercontent.com/dynatrace-wwse/codespaces-framework/${version}/mkdocs-base.yaml`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Failed to fetch mkdocs-base.yaml from ${url}: ${res.statusText}`);
  const text = await res.text();
  writeFileSync(baseYamlPath, text);
  console.log(`Downloaded mkdocs-base.yaml (version ${version}) successfully.`);
}
