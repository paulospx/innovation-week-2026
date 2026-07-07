**To create functions like `Where` and `Select` from LINQ in C#, the best and most idiomatic way is to write **extension methods**.** This lets you call them with the same fluent syntax as real LINQ.

### 1. Basic `Where` (Filter)

```csharp
using System;
using System.Collections.Generic;

public static class MyLinqExtensions
{
    public static IEnumerable<T> Where<T>(this IEnumerable<T> source, Func<T, bool> predicate)
    {
        if (source == null) throw new ArgumentNullException(nameof(source));
        if (predicate == null) throw new ArgumentNullException(nameof(predicate));

        foreach (var item in source)
        {
            if (predicate(item))
                yield return item;
        }
    }
}
```

**Usage:**

```csharp
var numbers = new[] { 1, 2, 3, 4, 5, 6 };

var even = numbers.Where(n => n % 2 == 0);
// Result: 2, 4, 6
```

### 2. Basic `Select` (Projection / Map)

```csharp
public static IEnumerable<TResult> Select<TSource, TResult>(
    this IEnumerable<TSource> source, 
    Func<TSource, TResult> selector)
{
    if (source == null) throw new ArgumentNullException(nameof(source));
    if (selector == null) throw new ArgumentNullException(nameof(selector));

    foreach (var item in source)
    {
        yield return selector(item);
    }
}
```

**Usage:**

```csharp
var names = new[] { "alice", "bob", "charlie" };

var upper = names.Select(n => n.ToUpper());
// Result: "ALICE", "BOB", "CHARLIE"
```

### 3. More Useful Overloads (Index-aware)

```csharp
public static IEnumerable<TResult> Select<TSource, TResult>(
    this IEnumerable<TSource> source, 
    Func<TSource, int, TResult> selector)  // with index
{
    if (source == null) throw new ArgumentNullException(nameof(source));
    if (selector == null) throw new ArgumentNullException(nameof(selector));

    int index = 0;
    foreach (var item in source)
    {
        yield return selector(item, index++);
    }
}
```

### 4. Chaining (Just like real LINQ)

```csharp
var result = numbers
    .Where(n => n > 2)
    .Select(n => n * 10)
    .Where(n => n < 50);
// Result: 30, 40
```

### 5. Advanced: `SelectMany` (Flatten)

```csharp
public static IEnumerable<TResult> SelectMany<TSource, TResult>(
    this IEnumerable<TSource> source,
    Func<TSource, IEnumerable<TResult>> selector)
{
    foreach (var item in source)
    foreach (var subItem in selector(item))
        yield return subItem;
}
```

### Full Minimal LINQ-like Class

```csharp
public static class CustomLinq
{
    public static IEnumerable<T> Where<T>(this IEnumerable<T> source, Func<T, bool> predicate)
    {
        foreach (var x in source) if (predicate(x)) yield return x;
    }

    public static IEnumerable<TResult> Select<TSource, TResult>(
        this IEnumerable<TSource> source, Func<TSource, TResult> selector)
    {
        foreach (var x in source) yield return selector(x);
    }

    public static IEnumerable<TResult> SelectMany<TSource, TResult>(
        this IEnumerable<TSource> source, Func<TSource, IEnumerable<TResult>> selector)
    {
        foreach (var x in source)
        foreach (var y in selector(x))
            yield return y;
    }
}
```

### Tips & Best Practices

- Use **`yield return`** for lazy evaluation (just like real LINQ).
- Add **null checks** in production code.
- For performance-critical code, you can optimize with `IList<T>` or `IReadOnlyList<T>` overloads to avoid enumerator overhead.
- If you want **deferred execution + reusability**, the iterator (`yield`) approach is perfect.
- You can also implement these on your own custom collection types.

Would you like a version that works with **async** streams (`IAsyncEnumerable<T>`), or a more complete implementation with `First`, `Any`, `Count`, etc.? Just let me know!


# Extension for database DataSet 

Generic extension:

```csharp
using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;

public static class DataSetExtensions
{
    /// <summary>
    /// Converts a List<T> to a DataSet containing a single DataTable.
    /// Uses reflection to map public properties of T to DataTable columns.
    /// </summary>
    /// <typeparam name="T">The type of items in the list.</typeparam>
    /// <param name="list">The list to convert.</param>
    /// <returns>A DataSet with one DataTable named after the type T.</returns>
    public static DataSet ToDataSet<T>(this List<T> list)
    {
        if (list == null)
        {
            throw new ArgumentNullException(nameof(list));
        }

        DataSet dataSet = new DataSet();
        DataTable dataTable = new DataTable(typeof(T).Name);

        // Get all public instance properties
        PropertyInfo[] properties = typeof(T).GetProperties(
            BindingFlags.Public | BindingFlags.Instance);

        // Create columns
        foreach (var prop in properties)
        {
            Type columnType = Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType;
            dataTable.Columns.Add(prop.Name, columnType);
        }

        // Populate rows
        foreach (var item in list)
        {
            if (item == null) continue;

            DataRow row = dataTable.NewRow();

            foreach (var prop in properties)
            {
                object value = prop.GetValue(item);
                row[prop.Name] = value ?? DBNull.Value;
            }

            dataTable.Rows.Add(row);
        }

        dataSet.Tables.Add(dataTable);
        return dataSet;
    }
}
```

Extension usage:

```csharp
public class Person
{
    public int Id { get; set; }
    public string Name { get; set; }
    public DateTime BirthDate { get; set; }
    public decimal Salary { get; set; }
    public bool IsActive { get; set; }
}

// Usage
List<Person> people = new List<Person>
{
    new Person { Id = 1, Name = "Alice", BirthDate = new DateTime(1990, 5, 15), Salary = 75000.50m, IsActive = true },
    new Person { Id = 2, Name = "Bob", BirthDate = new DateTime(1985, 3, 22), Salary = 92000m, IsActive = false }
};

DataSet dataSet = people.ToDataSet();

// Access the data
DataTable table = dataSet.Tables[0];
Console.WriteLine($"Table: {table.TableName}, Rows: {table.Rows.Count}");
```


