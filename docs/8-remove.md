# 8. Remove the deployment

Every `dtwiz install` has an `uninstall`. For Kubernetes it reverses step 5 in order: delete the
DynaKubes, wait for the pods the Operator manages to terminate, `helm uninstall` the Operator,
and delete the `dynatrace` namespace. It needs no token.

```bash
dtwiz uninstall kubernetes --yes
kubectl get namespace dynatrace
```

The second command reports `NotFound` once the namespace is gone. The cluster itself keeps
running; it belongs to your environment, not to dtwiz.

The check confirms that no DynaKube and no Operator pod remain. It fails while the Operator
runs. Check it:

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the Dynatrace Operator and its DynaKubes are removed"
buttonText: "Check removal"
command: "checkOperatorRemoved"
expect:
  operator: exit-zero
hint: "Run dtwiz uninstall kubernetes --yes. Namespace deletion can take a minute."
explanation: "Everything dtwiz install kubernetes created is gone; the cluster still runs."
-->

The Kubernetes entity stays visible in Dynatrace for its retention period: removing the
Operator stops new data, it does not delete what was sent. Your platform token is revoked by the
Enablement app when you terminate the session.

<!-- LAB_SOLUTION
reveal: |
  `dtwiz uninstall kubernetes --yes` deletes the DynaKubes, uninstalls the Operator Helm release
  and deletes the namespace. `checkOperatorRemoved` waits until no DynaKube and no Operator pod
  remain.
commands:
  - dtwiz uninstall kubernetes --yes
  - kubectl get namespace dynatrace
verify:
  - LAB_WAIT=1 checkOperatorRemoved
-->
