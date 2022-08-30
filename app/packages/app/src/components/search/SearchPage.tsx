import React from 'react';
import { Content, Header, Page } from '@backstage/core-components';
import { Grid, List, Card, CardContent } from '@material-ui/core';
import {
  SearchBar,
  SearchResult,
  DefaultResultListItem,
  SearchFilter,
} from '@backstage/plugin-search-react';
// import { CatalogSearchResultListItem } from '@backstage/plugin-catalog';

export const searchPage = (
  <Page themeId="home">
    <Header title="Search" />
    <Content>
      <Grid container direction="row">
        <Grid item xs={12}>
          <SearchBar />
        </Grid>
        <Grid item xs={3}>
          <Card>
            <CardContent>
              <SearchFilter.Select
                name="kind"
                values={['Component', 'Template']}
              />
            </CardContent>
            <CardContent>
              <SearchFilter.Checkbox
                name="lifecycle"
                values={['experimental', 'production']}
              />
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={9}>
          <SearchResult>
            {({ results }) => (
              <List>
                {results.map(result => {
                  switch (result.type) {
                    case 'software-catalog':
                      // return (
                      //   <CatalogResultListItem
                      //     key={result.document.location}
                      //     result={result.document}
                      //     highlight={result.highlight}
                      //   />
                      // );
                    default:
                      return (
                        <DefaultResultListItem
                          key={result.document.location}
                          result={result.document}
                          highlight={result.highlight}
                        />
                      );
                  }
                })}
              </List>
            )}
          </SearchResult>
        </Grid>
      </Grid>
    </Content>
  </Page>
);
