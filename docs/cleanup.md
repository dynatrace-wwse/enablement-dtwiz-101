# Cleanup

Undo the wizardry in reverse order:

```bash
# Stop and remove the schnitzel demo app
removeDtwizDemo

# Optionally remove the dtwiz CLI itself
dtwiz uninstall self --yes
```

Then stop the training environment from the platform that started it
(Enablement App **Terminate**, or delete the Codespace).

For local development, stop the Dev Container or any local port-forwarding
sessions you started during the lab.
