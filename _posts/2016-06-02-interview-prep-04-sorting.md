---
layout: post
title: Interview Prep 04 - Sorting
date: 2016-06-02
permalink: 'guides/interview-prep-04'
---

## {{ page.title }}

<hr class="left" />

In a previous exercise, we looked at how to find the index of an element in an array given an array that's already sorted. Today, we'll look at how to take an unsorted array and return a sorted array.

Sorting is a very popular algorithm problem, and there are many popular sorting algorithms.

When analyzing a sorting algorithm, the important things to check for are the time complexity, the space complexity, and whether the sort is "stable".

A sort is stable if two elements that are "tied" (i.e. have the same value for the key that we are sorting on) will be in the same order after the sort as they were before the sort.

For example, imagine we have an array of objects with a name and a phone number and we want to sort them by name. Let's say the array looks like this:

```js
[
    {name: "Jack Sprat", phone: 5555555511},
    {name: "Jane Sprat", phone: 5555555522},
    {name: "Jack Sprat", phone: 5555555533}
]
```

We have two people with the same name (Jack Sprat), so when we try to sort the array by name, there are two valid solutions:

```js
[
    {name: "Jack Sprat", phone: 5555555511},
    {name: "Jack Sprat", phone: 5555555533},
    {name: "Jane Sprat", phone: 5555555522}
]

[
    {name: "Jack Sprat", phone: 5555555533},
    {name: "Jack Sprat", phone: 5555555511},
    {name: "Jane Sprat", phone: 5555555522}
]
```

Both of these are valid because the items are correctly sorted by their names. The first solution above is what a "stable" sort algorithm will return, because the phone number ending with 11 comes before the phone number ending with 33 in both the input array and the output array. An "unstable" sorting algorithm may return either solution, but a stable sorting algorithm must return the first one.

### `insertionSort()`

Write a function called `insertionSort()` that will take an array of numbers as input and return a sorted version of the array as output.

Here's an outline of selection sort where `n` is the number of elements in the array.

- Start with `i = 0` and repeat until `i == n`
    - Let `j = i`
    - While there is still an element to the left and the loop hasn't already exited:
        - Compare element `j` with element `j-1`
        - If element `j` <= element `j-1`:
            - Swap elements `j` and `j-1`
            - Decrement `j`
        - Otherwise:
            - Exit the loop
    - Increment `i`

At the end of each iteration of the outer loop, the elements from `0` to `i` will be sorted.

Wikipedia contributor Swfung8 has created a [great animation](https://commons.wikimedia.org/w/index.php?title=File:Insertion-sort-example-300px.gif&oldid=187391701) of how insertion sort works:

![insertion sort](/img/guides/algorithms/insertion-sort.gif)

Once you're done with your insertion sort algorithm, run the test. The test for the "long random" array might take a few seconds to run (about 2s on my Cloud9 instance).

Is your insertion sort algorithm stable? If not, what could you change to make it stable (you'll probably only have to change one very minor detail if you followed the pseudo-code above). What is the time complexity of insertion sort? To figure it out, consider how many steps you need if there are two elements. Four elements?

### `mergeSort()`

Merge sort is a much more efficient sorting algorithm than `insertionSort()`. Merge sort is commonly used in production settings. It was invented/discovered by John von Neumann in 1945.

Merge sort works in two stages. In the first stage, the arrays are split in half until they are left with one element each. In the second stage, the sorted left and right half are merged back together.

Here is a more detailed description of how merge sort might be implemented recursively. `arr` is the name of the parameter passed to the function.

- If `arr` has only one element, it's already sorted, so just return `arr`
- Split the array in half. Call the left side `left` and the right side `right`.
- Recursively call `mergeSort` on the left and right halves and overwrite the `left` and `right` variables.
- We can now assume that `left` and `right` are sorted arrays.
- Create a new array to store the sorted results (`sorted`)
- Repeat until `left` and `right` are empty:
    - Compare the smallest element of `left` with the smallest element of `right` (the smallest element will be the first element in each list because we know they are sorted).
    - Remove whichever element is smaller from its respective list and put it at the end of `sorted` (JS arrays have a `push` function to add an element at the end)
- Once left and right are empty, then `sorted` is finished, so we're done.
- Return `sorted` to finish.

Wikipedia contributor Swfung8 has created another [great animation](https://commons.wikimedia.org/w/index.php?title=File:Merge-sort-example-300px.gif&oldid=187394693) of how merge sort works:

![merge sort](/img/guides/algorithms/merge-sort.gif)

After you code up the algorithm, run the tests! If you did everything correctly, the merge sort should be much faster than the insertion sort for the long random.

Calculating the computational complexity of merge sort is trickier than analyzing insertion sort.

Khan Academy's algorithms course has a great explanation of how to analyze the time and space complexity of merge sort. Check it out [here](https://www.khanacademy.org/computing/computer-science/algorithms/merge-sort/a/analysis-of-merge-sort).

Heuristically, when you see an algorithm that takes a divide and conquer approach to a problem (such as merge sort, binary search, or the 1-D peak finding algorithm), the complexity will be related to `O(log(n))` with a base two logarithm. If a step in the algorithm involves recursively dividing the data structure in half, it's quite likely that you will have to double the size of the input to get the dividing part of the algorithm to take an extra step.

To get to the `O(n*log(n))` step, you can remember a rule that there is no array sort algorithm that has better average case performance than `O(n*log(n))`. Therefore, merge sort has to be at least `O(n*log(n))`. Thinking about the merging (conquer) part of the algorithm, you can see that the number of comparisons grows linearly (to understand why, read the Khan Academy analysis listed above).

NOTE: The above reasoning is purely a heuristic. It is meant as a way to help you quickly remember performance of various algorithms -- not as a way to actually analyze an algorithm. If you are asked to analyze the complexity of a search algorithm in an interview, it is not very good to answer the question with a line of reasoning like "comparison search algorithms have average/worst case performance of at least `O(n*log(n))`". The correct answer to that question in an interview would be an analysis like the one by Khan Academy.

Is merge sort a stable sorting algorithm? How would you test it (hint: you are going to have to sort something other than just integers).
