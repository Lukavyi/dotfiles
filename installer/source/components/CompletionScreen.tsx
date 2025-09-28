import type { FC } from 'react';
import { Box, Text } from 'ink';

interface CompletionScreenProps {
  selections: string[];
}

const CompletionScreen: FC<CompletionScreenProps> = ({ selections }) => {
  const hasSelections = selections.length > 0;

  const completionMessage = hasSelections
    ? '✓ Installation complete!'
    : 'No components were installed';

  return (
    <Box flexDirection="column">
      <Text color="green" bold>
        {completionMessage}
      </Text>
      {hasSelections && (
        <Box marginTop={1} flexDirection="column">
          <Text>Next step:</Text>
          <Text> • Restart your shell or run: source ~/.zshrc</Text>
        </Box>
      )}
    </Box>
  );
};

export default CompletionScreen;