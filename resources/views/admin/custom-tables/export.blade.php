<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid black; padding: 5px 10px; text-align: left; }
        th { background-color: #f0f0f0; font-weight: bold; }
    </style>
</head>
<body>
    <table>
        <thead>
            <tr>
                <th>№</th>
                @foreach ($columns as $col)
                    <th>{{ $col['name'] }}</th>
                @endforeach
                <th>Создана</th>
                <th>Обновлена</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($rows as $index => $row)
                <tr>
                    <td>{{ $index + 1 }}</td>
                    @foreach ($columns as $col)
                        <td>{{ $row->data[$col['key']] ?? '' }}</td>
                    @endforeach
                    <td>{{ $row->created_at?->format('d.m.Y H:i') }}</td>
                    <td>{{ $row->updated_at?->format('d.m.Y H:i') }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
