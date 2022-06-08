// In packages/backend/src/plugins/kubernetes.ts
import { KubernetesBuilder } from '@backstage/plugin-kubernetes-backend';
import { Router } from 'express';
import { PluginEnvironment } from '../types';

export default async function createPlugin(
  env: PluginEnvironment,
): Promise<Router> {
  const { router } = await KubernetesBuilder.createBuilder({
    logger: env.logger,
    config: env.config,
  }).build();
  return router;
}
