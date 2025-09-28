import React, { type FC } from 'react';
import { Box, Text } from 'ink';
import type { Categories } from '../config.js';

interface CategoryListProps {
  categories: Categories;
  selections: string[];
  cursor: number;
}

const CategoryList: FC<CategoryListProps> = ({
  categories,
  selections,
  cursor,
}) => {
  const flatItems = Object.entries(categories).flatMap(
    ([categoryName, items]) =>
      items.map((item, index) => ({
        ...item,
        categoryName,
        isFirstInCategory: index === 0,
      }))
  );

  return (
    <Box flexDirection="column">
      {flatItems.map((item, index) => (
        <React.Fragment key={item.id}>
          {item.isFirstInCategory && (
            <Box marginTop={index > 0 ? 1 : 0}>
              <Text color="cyan" bold>
                {item.categoryName}
              </Text>
            </Box>
          )}
          <Box marginLeft={2}>
            <Text color={index === cursor ? 'yellow' : 'white'}>
              {index === cursor ? '> ' : '  '}[
              {selections.includes(item.id) ? 'x' : ' '}] {item.name}
            </Text>
            <Text dimColor> - {item.description}</Text>
          </Box>
        </React.Fragment>
      ))}
    </Box>
  );
};

export default CategoryList;
