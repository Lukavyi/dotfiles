import type { FC } from 'react';
import { Box, Text } from 'ink';
import type { Categories } from '../config.js';

interface SummaryProps {
  categories: Categories;
  selections: string[];
}

const Summary: FC<SummaryProps> = ({ categories, selections }) => {
  const selectedItems = Object.values(categories)
    .flat()
    .filter((item) => selections.includes(item.id));

  return (
    <Box flexDirection="column">
      <Text color="green" bold>
        Selected components to install:
      </Text>
      {selectedItems.length === 0 ? (
        <Box marginLeft={2}>
          <Text color="yellow">No components selected</Text>
        </Box>
      ) : (
        selectedItems.map((item) => (
          <Box key={item.id} marginLeft={2}>
            <Text>• {item.name}</Text>
          </Box>
        ))
      )}
    </Box>
  );
};

export default Summary;
