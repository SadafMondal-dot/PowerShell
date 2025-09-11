# ===============================
# PowerShell Script: Customer Data Analysis
# ===============================

# Define file paths
# Input file comes from the C: drive root
$InputFile = "C:\Customer.csv"

# Output folder will be on the Desktop
$OutputFolder = "C:\"

# Output CSV file path
$OutputFile = Join-Path $OutputFolder "Customer_Filtered.csv"

# Output chart image path
$ChartFile = Join-Path $OutputFolder "Customer_Histogram.png"

Write-Output "Starting script execution..."

# Step 1: Check if input file exists
if (-Not (Test-Path $InputFile)) {
    Write-Output "Input file not found: $InputFile"
    exit
}
Write-Output "Input file located successfully."

# Step 2: Create output folder if it does not exist
if (-Not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory | Out-Null
    Write-Output "Output folder created: $OutputFolder"
} else {
    Write-Output "Output folder already exists: $OutputFolder"
}

# Step 3: Import CSV data
$CustomerData = Import-Csv -Path $InputFile
Write-Output "Customer data imported successfully."

# Step 4: Select only Gender, Age, and Spending Score columns
$FilteredData = $CustomerData | Select-Object Gender, Age, 'Spending Score (1-100)'
Write-Output "Filtered columns: Gender, Age, Spending Score (1-100)."

# Step 5: Export the filtered data to new CSV
$FilteredData | Export-Csv -Path $OutputFile -NoTypeInformation
Write-Output "Filtered data exported to: $OutputFile"

# Step 6: Calculate correlations
# Convert Age and Spending Score into numbers
$Ages = $FilteredData.Age | ForEach-Object { [int]$_ }
$Scores = $FilteredData.'Spending Score (1-100)' | ForEach-Object { [int]$_ }

# Simple correlation calculation function
function Get-Correlation($X, $Y) {
    $count = $X.Count
    $avgX = ($X | Measure-Object -Average).Average
    $avgY = ($Y | Measure-Object -Average).Average

    $numerator = 0
    $denominatorX = 0
    $denominatorY = 0

    for ($i=0; $i -lt $count; $i++) {
        $diffX = $X[$i] - $avgX
        $diffY = $Y[$i] - $avgY
        $numerator += ($diffX * $diffY)
        $denominatorX += ($diffX * $diffX)
        $denominatorY += ($diffY * $diffY)
    }

    return $numerator / ([math]::Sqrt($denominatorX * $denominatorY))
}

$CorrelationAgeScore = Get-Correlation $Ages $Scores
Write-Output "Correlation between Age and Spending Score: $CorrelationAgeScore"

# Step 7: Generate histogram chart
Add-Type -AssemblyName System.Windows.Forms.DataVisualization
$Chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$Chart.Width = 800
$Chart.Height = 600

# Create chart area
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$Chart.ChartAreas.Add($ChartArea)

# Create series for Age vs Spending Score
$Series = New-Object System.Windows.Forms.DataVisualization.Charting.Series "AgeVsScore"
$Series.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Column
$Series.IsValueShownAsLabel = $true

# Group by Age and calculate average Spending Score
$GroupedData = $FilteredData | Group-Object -Property Age | ForEach-Object {
    $avgScore = ($_.Group.'Spending Score (1-100)' | Measure-Object -Average).Average
    [PSCustomObject]@{ Age = $_.Name; AvgScore = [math]::Round($avgScore,2) }
}

foreach ($row in $GroupedData) {
    $point = $Series.Points.AddXY($row.Age, $row.AvgScore)
}

$Chart.Series.Add($Series)

# Add titles
$Chart.Titles.Add("Age vs Spending Score Histogram")
$Chart.ChartAreas[0].AxisX.Title = "Age"
$Chart.ChartAreas[0].AxisY.Title = "Average Spending Score"

# Save chart as PNG
$Chart.SaveImage($ChartFile, "Png")
Write-Output "Histogram chart saved as: $ChartFile"

Write-Output "Script execution completed successfully."