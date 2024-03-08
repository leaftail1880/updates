// @ts-check

import { spawnSync } from "child_process";
import path from "path";

import "jsonminify";
import { Committer, fordir } from "leafy-utils";

const mojang =
	"../../AppData/Local/Packages/Microsoft.MinecraftUWP_8wekyb3d8bbwe/LocalState/games/com.mojang";
const folder = "StealTimize-DEV";
const pathTo = "./temp";
const packUUID = "12232017-1101-0000-a004-a1b2c3d4e5f6";
const rpUUID = "12232017-1101-0001-a004-a1b2c3d4e5f6";

/** @type {(buffer: Buffer) => {data: Buffer}} */
function allowed(buffer) {
	return { data: buffer };
}

async function main() {
	async function precommit(arg) {
		await fordir({
			ignoreFolders: ["$green"],
			ignoreFiles: [],
			inputPath: path.join(mojang, "development_resource_packs", folder),
			outputPath: pathTo,
			extensions: {
				".json"(buffer, _, filename) {
					if (filename.startsWith("$")) return { data: "{}", modified: false };

					let newText = JSON.minify(buffer.toString());
					if (filename === "manifest.json") {
						const manifest = JSON.parse(newText);
						manifest.header.uuid = packUUID;
						manifest.header.version = arg.version ?? manifest.header.version;
						manifest.header.name = `§l§f§o§k||§r §bSteal§dTimize §7${manifest.header.version.join(
							"."
						)}§r`;
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

		spawnSync(
			`powershell.exe -Command "Compress-7Zip ${pathTo} -ArchiveFileName ./StealTimize/Packet.zip; Copy-Item ./StealTimize/Packet.zip ./StealTimize/StealTimize.mcpack; Remove-Item ${pathTo} -Recurse -Force"`,
			{ shell: true, stdio: "inherit" }
		);
	}

	if (process.argv[2] !== "test") {
		Committer.precommit = precommit;

		await Committer.commit();
	} else {
		precommit({});
	}
}

main();
