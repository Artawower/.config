import asyncio
import os
from pathlib import Path
from typing import Any, cast

from rassumfrassum.frassum import LspLogic, Server
from rassumfrassum.json import JSON
from rassumfrassum.util import dmerge, info


def _find_workspace_folder(scope_uri: str) -> dict | None:
    if not scope_uri.startswith('file://'):
        return None

    path = scope_uri[7:]
    current = os.path.dirname(path)

    while current and current != '/':
        if os.path.exists(os.path.join(current, 'package.json')):
            return {
                'uri': f'file://{current}',
                'name': os.path.basename(current),
            }
        parent = os.path.dirname(current)
        if parent == current:
            break
        current = parent

    return None


def _eslint_config(workspace_folder: dict | None) -> dict:
    cfg = {
        'validate': 'probe',
        'problems': {},
        'rulesCustomizations': [],
        'nodePath': None,
    }
    if workspace_folder:
        cfg['workspaceFolder'] = workspace_folder
    return cfg


async def _find_tsdk() -> str | None:
    try:
        proc = await asyncio.create_subprocess_exec(
            'node',
            '-p',
            "require.resolve('typescript/lib')",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, _ = await proc.communicate()
        return stdout.decode().strip()
    except Exception:
        return None


class VueEslintLogic(LspLogic):
    async def on_client_request(self, method: str, params: JSON, servers: list[Server]):
        if method == 'initialize':
            tsdk = await _find_tsdk()
            if tsdk:
                params['initializationOptions'] = dmerge(
                    params.get('initializationOptions') or {},
                    {
                        'typescript': {'tsdk': tsdk},
                        'vue': {'hybridMode': False},
                    },
                )
        return await super().on_client_request(method, params, servers)

    async def on_client_response(
        self,
        method: str,
        request_params: JSON,
        response_payload: JSON,
        is_error: bool,
        server: Server,
    ):
        if (
            method == 'workspace/configuration'
            and not is_error
            and 'eslint' in server.name.lower()
        ):
            info("Enriching workspace/configuration for ESLint")
            req_items = request_params.get('items', [])
            res_items = cast(list[Any], response_payload)

            if len(res_items) < len(req_items):
                res_items.extend([None] * (len(req_items) - len(res_items)))

            for i, item in enumerate(req_items):
                if item.get('section', '') == '':
                    wfolder = _find_workspace_folder(item.get('scopeUri', ''))
                    cfg = _eslint_config(wfolder)
                    res_items[i] = (
                        dmerge(res_items[i], cfg)
                        if isinstance(res_items[i], dict)
                        else cfg
                    )

        await super().on_client_response(
            method, request_params, response_payload, is_error, server
        )


def servers():
    return [
        ['vue-language-server', '--stdio'],
        ['vscode-eslint-language-server', '--stdio'],
    ]


def logic_class():
    return VueEslintLogic
