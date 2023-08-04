// @ts-check

import { spawn } from "child_process";
import path from "path";

import "jsonminify";
import { fordir } from "leafy-utils";

const mojang =
	"../../AppData/Local/Packages/Microsoft.MinecraftUWP_8wekyb3d8bbwe/LocalState/games/com.mojang";
const folder = "StelTimize-DEV";
const pathTo = "./temp";
const packUUID = "12232017-1101-0000-a004-a1b2c3d4e5f6";
const rpUUID = "12232017-1101-0001-a004-a1b2c3d4e5f6";

/** @type {(buffer: Buffer) => {data: Buffer}} */
function allowed(buffer) {
	return { data: buffer };
}

async function main() {
	await fordir({
		ignoreFolders: [".vscode", "$OLD"],
		ignoreExtensions: [],
		ignoreFiles: [],
		inputPath: path.join(mojang, "development_resource_packs", folder),
		outputPath: pathTo,
		extensions: {
			".json"(buffer, _, filename) {
				if (filename.startsWith("$")) return { data: "{}", modified: false };

				let newText = JSON.minify(Buffer.from(buffer).toString());
				if (filename === "manifest.json") {
					const manifest = JSON.parse(newText);
					manifest.header.uuid = packUUID;
					manifest.modules[0].uuid = rpUUID;
					newText = JSON.stringify(manifest);
				}
				return { data: newText };
			},
			".png": allowed,
			".txt": allowed,
			".lang": allowed,
		},
		silentMode: false,
	});

	spawn(
		`powershell.exe -Command "Compress-Archive -Path ${pathTo} -DestinationPath ./StelTimize/packet.zip -Update; Remove-Item ${pathTo} -Recurse"`,
		{ shell: true, stdio: "inherit" }
	);
}

main();
