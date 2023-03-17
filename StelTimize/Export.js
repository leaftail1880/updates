// @ts-check

import { spawn } from "child_process";
import path from "path";

import "jsonminify";
import { fordir } from "leafy-utils";

const mojang =
	"../../../AppData/Local/Packages/Microsoft.MinecraftUWP_8wekyb3d8bbwe/LocalState/games/com.mojang";
const folder = "Steltimize";
const pathTo = "./temp";

/** @type {(buffer: Buffer) => {data: Buffer}} */
function allowed(buffer) {
	return { data: buffer };
}

async function main() {
	await fordir({
		inputPath: path.join(mojang, "development_resource_packs", folder),
		outputPath: pathTo,
		extensions: {
			".json"(buffer, givenpath, filename) {
				const basepath = path.parse(givenpath).base;
				if (filename.startsWith("$") || [".vscode", "$OLD"].includes(basepath))
					return { data: "{}", modified: false };

				const newText = JSON.minify(Buffer.from(buffer).toString());
				return { data: newText };
			},
			".png": allowed,
			".txt": allowed,
			".lang": allowed,
		},
		silentMode: false,
	});

	spawn(
		`powershell.exe -Command "Compress-Archive -Path ${pathTo} -DestinationPath ./${folder}/packet.zip -Update; Remove-Item ${pathTo} -Recurse"`,
		{ shell: true, stdio: "inherit" }
	);
}

main();
