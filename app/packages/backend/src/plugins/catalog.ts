// import { CatalogBuilder } from '@backstage/plugin-catalog-backend';
import { CatalogBuilder, EntityProvider } from '@backstage/plugin-catalog-backend';
import { ScaffolderEntitiesProcessor } from '@backstage/plugin-scaffolder-backend';
import { Router } from 'express';
import { PluginEnvironment } from '../types';
// import { GitHubOrgEntityProvider } from '@backstage/plugin-catalog-backend-module-github';

import { ScmIntegrations, DefaultGithubCredentialsProvider } from '@backstage/integration';
import { GitHubOrgEntityProvider } from '@backstage/plugin-catalog-backend-module-github';


export default async function createPlugin(
  env: PluginEnvironment,
): Promise<Router> {
  const builder = await CatalogBuilder.create(env);

  // The org URL below needs to match a configured integrations.github entry
  // specified in your app-config.

  // builder.addEntityProvider(
  //   GitHubOrgEntityProvider.fromConfig(env.config, {
  //     id: 'production',
  //     orgUrl: 'https://github.com/devxp-tech',
  //     logger: env.logger,
  //     schedule: env.scheduler.createScheduledTaskRunner({
  //       frequency: { minutes: 60 },
  //       timeout: { minutes: 15 },
  //     }),
  //   }),
  // );

  const integrations = ScmIntegrations.fromConfig(env.config);

  const githubCredentialsProvider = DefaultGithubCredentialsProvider.fromIntegrations(integrations);

  const gitProvider = GitHubOrgEntityProvider.fromConfig(env.config, {
    id: "github-org-entity-provider",
    orgUrl: "https://github.com/devxp-tech", // 🚨 REPLACE
    logger: env.logger,
    githubCredentialsProvider
  });

  builder.addEntityProvider(gitProvider as EntityProvider);

  // builder.addProcessor(new ScaffolderEntitiesProcessor());

  const { processingEngine, router } = await builder.build();
  // await processingEngine.start();
  await gitProvider.read();
  return router;
}
