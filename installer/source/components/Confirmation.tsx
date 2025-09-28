import type { FC } from 'react';
import { Box, Text } from 'ink';
import Summary from './Summary.js';
import type { Categories } from '../config.js';

interface ConfirmationProps {
  categories: Categories;
  selections: string[];
}

const Confirmation: FC<ConfirmationProps> = ({
  categories,
  selections,
}) => {
  return (
    <Box flexDirection="column">
      <Summary categories={categories} selections={selections} />
      <Box marginTop={1}>
        <Text>
          Proceed with installation? (y/n)
        </Text>
      </Box>
    </Box>
  );
};

export default Confirmation;