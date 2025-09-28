import { useState, useMemo, useCallback } from 'react';
import type { Categories } from '../config.js';

export type FlatItem =
  | {
      id: string;
      name: string;
      description: string;
      categoryName: string;
      isCategory: true;
    }
  | {
      id: string;
      name: string;
      description: string;
      categoryName: string;
      isCategory: false;
      script: string;
      profile?: 'work' | 'personal' | 'all';
      details: string[];
    };

export const useNavigation = (categories: Categories) => {
  const [cursor, setCursor] = useState(0);

  // Create a flat list of all navigable items with full data
  const flatItems = useMemo(() => {
    const items: FlatItem[] = [];

    Object.entries(categories).forEach(([categoryName, categoryItems]) => {
      // Add category header
      items.push({
        id: `category-${categoryName}`,
        name: categoryName,
        description: `Select/deselect all items in ${categoryName}`,
        categoryName,
        isCategory: true,
      });

      // Add items with full data
      categoryItems.forEach((item) => {
        items.push({
          id: item.id,
          name: item.name,
          description: item.description,
          categoryName,
          isCategory: false,
          script: item.script,
          profile: item.profile,
          details: item.details,
        });
      });
    });

    return items;
  }, [categories]);

  const totalItems = flatItems.length;

  // Navigation functions
  const moveUp = useCallback(() => {
    setCursor((prev) => (prev - 1 + totalItems) % totalItems);
  }, [totalItems]);

  const moveDown = useCallback(() => {
    setCursor((prev) => (prev + 1) % totalItems);
  }, [totalItems]);

  // Get current item
  const getCurrentItem = useCallback(() => {
    return flatItems[cursor];
  }, [cursor, flatItems]);

  // Get all item IDs in a category
  const getCategoryItemIds = useCallback(
    (categoryName: string): string[] => {
      return categories[categoryName]?.map((item) => item.id) || [];
    },
    [categories]
  );

  return {
    cursor,
    moveUp,
    moveDown,
    getCurrentItem,
    getCategoryItemIds,
    totalItems,
    flatItems,
  };
};
