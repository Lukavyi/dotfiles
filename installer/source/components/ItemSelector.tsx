import { type FC } from 'react';
import { Box, Text } from 'ink';
import type { Categories } from '../config.js';
import type { FlatItem } from '../hooks/useNavigation.js';

interface ItemSelectorProps {
  categories: Categories;
  selections: string[];
  cursor: number;
  profile: 'work' | 'personal';
  flatItems: FlatItem[];
}

const ItemSelector: FC<ItemSelectorProps> = ({
  categories,
  selections,
  cursor,
  profile,
  flatItems,
}) => {
  // Get all item IDs in a category for toggle functionality
  const getCategoryItemIds = (categoryName: string): string[] => {
    return categories[categoryName]?.map((item) => item.id) || [];
  };

  // Check if all items in a category are selected
  const isCategoryFullySelected = (categoryName: string): boolean => {
    const itemIds = getCategoryItemIds(categoryName);
    return itemIds.length > 0 && itemIds.every((id) => selections.includes(id));
  };

  // Check if some (but not all) items in a category are selected
  const isCategoryPartiallySelected = (categoryName: string): boolean => {
    const itemIds = getCategoryItemIds(categoryName);
    const selectedCount = itemIds.filter((id) =>
      selections.includes(id)
    ).length;
    return selectedCount > 0 && selectedCount < itemIds.length;
  };

  return (
    <Box flexDirection="column">
      <Box>
        <Text color="green" bold>
          🏠 Dotfiles Manager
        </Text>
        <Text color="magenta" bold>
          {' '}
          [Profile: {profile === 'work' ? 'Work' : 'Personal'}]
        </Text>
      </Box>
      <Text dimColor>
        ↑↓ Navigate • Space: Toggle • Tab: Switch Profile • a: Select all •
        Enter: Confirm
      </Text>
      <Box marginTop={1} flexDirection="column">
        {flatItems.map((item, index) => {
          const isSelected = index === cursor;

          if (item.isCategory) {
            const isFullySelected = isCategoryFullySelected(item.categoryName);
            const isPartiallySelected = isCategoryPartiallySelected(
              item.categoryName
            );

            return (
              <Box key={item.id} marginTop={index > 0 ? 1 : 0}>
                <Text
                  color={isSelected ? 'yellow' : 'cyan'}
                  bold
                  underline={isSelected}
                >
                  {isSelected ? '▶ ' : '  '}
                  {item.name}
                  {isFullySelected
                    ? ' [✓]'
                    : isPartiallySelected
                    ? ' [~]'
                    : ' [ ]'}
                </Text>
              </Box>
            );
          }

          return (
            <Box key={item.id} flexDirection="column" marginLeft={2}>
              <Box>
                <Text color={isSelected ? 'yellow' : 'white'}>
                  {isSelected ? '> ' : '  '}[
                  {selections.includes(item.id) ? 'x' : ' '}] {item.name}
                </Text>
                <Text dimColor> - {item.description}</Text>
              </Box>
              {isSelected && item.details && (
                <Box marginLeft={5} flexDirection="column">
                  {item.details.map((detail, i) => (
                    <Text key={i} dimColor>
                      → {detail}
                    </Text>
                  ))}
                </Box>
              )}
            </Box>
          );
        })}
      </Box>
    </Box>
  );
};

export default ItemSelector;
