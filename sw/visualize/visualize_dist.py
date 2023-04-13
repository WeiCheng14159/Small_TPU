import matplotlib.pyplot as plt
import numpy as np


def plot_distribution(array, file_name="dist.png"):
    # Define the figure and axes for the plot
    fig, ax = plt.subplots()

    # Plot a histogram of the array values with 20 bins
    ax.hist(array, bins=100)

    # Set the axis labels and title
    ax.set_xlabel("Value")
    ax.set_ylabel("Frequency")
    ax.set_title("Value Distribution")

    # Show the plot
    plt.savefig(file_name)
